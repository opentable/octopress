---
layout: post
title: "Acceptance Now"
date: 2014-05-20 15:00:00 +0100
comments: true
author: ssalisbury
categories: [Testing, Engineering, Acceptance tests, Innovation]
---
_When is acceptance-only testing a good idea, and how can its problems be overcome?_

In [a recent post], I espoused some of the benefits my team enjoyed by reducing our test-base to a single layer of acceptance tests, with no separate unit or integration tests. It caused [some minor controversy], which was not to be unexpected. At the time, I knew I had left out some details for brevity's sake. In this post—spurred on by some interesting [questions] and [commentary]—I'd like to offer a more constructive view on the subject, and dig a little deeper into the nitty gritty of how we made it work.

I'll also point out some other hidden benefits of moving to acceptance-only testing, and suggest synergistic practices that can help decide if this is the right approach for your project.

[a recent post]:/blog/2014/04/16/look-ma-no-unit-tests
[some minor controversy]:http://www.reddit.com/r/programming/comments/237fr1/look_ma_no_unit_tests/
[questions]:https://twitter.com/NathanGloyn/status/456756552092098561
[commentary]:http://www.reddit.com/r/programming/comments/237fr1/look_ma_no_unit_tests/cgujuv7

## Seams
After-the-fact unit testing requires us to [find the seams] along which code can be isolated and tested. Where those seams don't exist,  the temptation is to refactor code until they do, using patterns like [dependency injection], and following [SRP] and other [SOLID] patterns.

[Test-first unit testing] aka TDD naturally tends to maximise seams, and results in highly decoupled code with small, specific tests. TDD must result in 100% unit test coverage, if practiced according to [the gospel]. In other words, TDD results in the best kind of code for later [modification without risk], and the best tests for detailed, granular feedback. Unit tests also tend to run very quickly, sometimes fast enough to [run every time you hit "Save"].
 
**Acceptance testing has far fewer seams available.** Typically only one: the application boundary. Yes: _Your tests must invoke the entire application each time they are run._ Thus running acceptance tests is potentially very slow for even moderately sized projects with few dependencies—let alone large ones with many. Another problem is that, when an acceptance test fails, the failure could be at _any_ layer in the stack. You immediately lose the pinpoint specificity afforded by unit tests.

Why, then, is it sometimes a good idea to forgo unit- in favour of acceptance-tests?

As we will see, the first issue, performance, can be mitigated. The second, granularity, is more difficult to overcome. But sometimes _that might be okay._

[find the seams]:https://www.youtube.com/watch?v=wEhu57pih5w
[dependency injection]:http://martinfowler.com/articles/injection.html
[SRP]:http://en.wikipedia.org/wiki/Single_responsibility_principle
[SOLID]:http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod
[Test-first unit testing]:http://en.wikipedia.org/wiki/Test-driven_development
[The Gospel]:http://en.wikipedia.org/wiki/Test-Driven_Development_by_Example
[modification without risk]:http://sourcemaking.com/refactoring
[run every time you hit "Save"]:http://misko.hevery.com/2009/05/07/configure-your-ide-to-run-your-tests-automatically/

## Performance
In most cases I have seen, acceptance tests are _really_ slow. In some cases, there might be nothing you can do, but usually there is. Front-end automation suites using Selenium are temporally incorrigible, but they can be parallelised. Complex transactional pieces might be irreducible, but they can be helped with mock data. No matter which box your code is in, there is probably an escape route. Following are some of the techniques we used to overcome performance bottlenecks in our acceptance test suite...
 
### Performance: Sandbox Data
_This is probably a topic that deserves its own post, but I'll try to give a high-level treatment here._
In our project, we took on the overhead of providing mock "sandbox" data. For our consumers this was a required feature anyway, so implementing it began early in the project, well before we [deleted all the unit tests]. It turned out this was an important enabler in moving to acceptance-only, since it allowed us to run tests much faster by _sometimes_ circumventing data access.

Since this project was written in C# using strict TDD, our data layer already had [an interface] for each data source. In the _unit_ tests this allowed us to easily stub out the data. We reused the same interfaces to build up our sandbox, with dependency injection at runtime to choose between real and mock data. (I like to call this a 'pseudoseam' in that it allows us to isolate data access at runtime, just like an ordinary seam allows you to isolate classes and methods in test.)

_Sandbox data is hard to implement. A lot of the effort that would have gone into unit tests and their manitenance was instead pumped into writing good, wholesome, fake data for the sandbox._ However, sandbox data, unlike unit tests, solves three problems at once:

* It lets your _consumers_ test in a predictable way without making real transactions;
* It enables you to record specific data conditions from The Real World™, increasing your understanding of that data;
* It lets you test internal business logic independently from real data, fast.

_Snip!_ I went into too much detail on sandbox data here, saving that for a future post.

[deleted all the unit tests]:/blog/2014/04/16/look-ma-no-unit-tests
[an interface]:http://en.wikipedia.org/wiki/Interface_(computer_science)#Software_interfaces_in_object-oriented_languages


### Performance: Loosen isolation
Isolation between test runs is really important. If the order you run tests in can ever alter the results, then you have shared state, and you can no longer trust that your tests are testing the same thing each time they are run.

Usually, in unit testing, we rely on the test runner to respect directives in code that enforce isolation in this way. In NUnit with C# we use attributes for [set-up] and [tear-down], for example. We usually throw away the entire object graph before each test. _Sometimes before each assertion._ For acceptance testing, where spinning up your test subject tends to take longer, it can be helpful to bend the rules somewhat.

[set-up]:http://www.nunit.org/index.php?p=setup&r=2.2.10
[tear-down]:http://www.nunit.org/index.php?p=teardown&r=2.2.10

In an ideal world, each test run would begin on a new, freshly installed OS, thus eliminating any possibility of differing test results due to environmental issues—the system clock and network state notwithstanding. For unit testing we rarely if ever take this extremist approach. More usual is to rely on the test runner to enforce "similar enough" initial conditions each time a test is run–commonly relying on the developer to write this set-up and tear-down code correctly.

In acceptance testing it can be very beneficial for performance to loosen this one step further and re-use the same application instance (process) between test runs. Sandboxed data, especially if it is immutable, can help enormously to avoid the pitfalls of shared state. When running your acceptance tests against real data, where shared state is a real concern, you may discover interesting bugs that would otherwise have gone unnoticed if you were using only unit tests. **Upon the discovery of issues with real data, you must implement the same failing condition in your sandbox data so that you don't accidentally introduce regressions later.**

The way we initially achieved this in our acceptance tests was by using the `TestFixtureSetup` attribute from NUnit to invoke the application, and run it to a point where it had generated an interesting result. Then, each 'test' is in fact a single assertion on the state of the world at that point. Like this:

```csharp
[TestFixture]
public class my_acceptance_tests
{
    [TestFixtureSetUp]
    public void do_stuff()
    {
        _result = InvokeTheApplicationsWithSomeGivenParams();
    }
    [Test]
    public void it_is_cool()
    {
        Assert.That(_result.Coolness, Is.GreaterThan(1337));
    }
    [Test]
    public void it_has_2_bananas()
    {
        Assert.That(_result.Bananas, Is.EqualTo(2));
    }
    .
    .
    .
}
```

We eventually refined this to use constructors to set up the initial state, and did some other not-necessarily-normal things to coax our acceptance tests into a reasonably elegant suite. More on this in an upcoming post on sandbox data.
 
## Granularity
Granularity, in this case, refers to the level of detail revealed by a failing test. When a _unit_ test fails, if it's written correctly, you should immediately know which method in which class went wrong. Often, the call stack in the exception message will tell you exactly which line of code was at fault. You can immediately jump to the offending code.

With acceptance tests, when something goes wrong, it could be anywhere in your program. Any of the tens, hundreds, thousands, or even millions of lines of code in your program could be at fault. This is clearly less than ideal, however there are ways to mitigate the pain:

### Minimise Code, Maximise Seams
Clearly, the fewer lines of code in your app, the easier it will be to hunt down obscure test failures. However some problems are too big to be solved with few lines of code. What then to do? One answer, which we are beginning to explore in a new project, may be to write many small programs, each of which solves only a small part of the problem domain. This approach is known as [microservices], and certainly has its own complexities in threading together many small pieces at OS or network level. However, a microservices architecture has additional potential benefits tangential to its affinity with acceptance-only testing. I'm planning a blog post on this subject soon, once we have more data.

[microservices]:http://martinfowler.com/articles/microservices.html

### Debugfu
This isn't really a way to make your tests more granular, but it can help mitigate the problems of low granularity in acceptance tests. If the test won't tell you which line of code went wrong, attach a debugger to find out! If you're using Visual Studio, you are blessed with a best-of-breed debugger. Use it, trace through the execution and try to spot what went wrong. Use bookmarks and breakpoints to index your code. Does one area of code cause problems time and time again? There is probably something wrong with it, see if it can be rewritten more clearly. Users of  IntelliJ IDEA, Eclipse, or a myriad other IDEs, will also have access to usable debuggers.

### Sandbox Data (Again)
Sandbox data allows you to run your tests against very specific data conditions. Often your code will have a different execution path depending on data, and this is really valuable knowledge when trying to nail down the cause of a test failure. Sandbox data, that can be selected by your tests, will improve the percieved granularity of such, by limiting the potential execution paths.

## Benefits
I mentioned a few of the benefits of moving to acceptance-only testing in my last post. However, a few more have come to light since then which are worth mentioning.

### Acceptance Tests Are Language-Agnostic
After writing v1 of our API, and acceptance-testing the living daylights out of it, we realised that we were still probably maintaining too much code, this time in the application itself. We decidede to port the whole thing to JavaScript using Node to see what it would be like.

It worked, and _we didn't have to touch a single test,_ even though those tests were written in C#, and the application was in JavaScript.

Just imagine the overhead of porting hundreds of unit tests over to a different language, along with the application. If that had been a requirement of our experiment, it would not have happened, and we would not have learned what we did. _(In the end we did keep using the C# implementation in production, but the speedy rewrite was still a valuable learning aid.)_

### Acceptance Tests Behave Exactly Like Your Users
When an acceptance-level test passes, you can be confident that a whole user journey using your application is working correctly. That's a huge win. When one fails, you can be pretty confident that something important to your users is not working properly and needs attention. Also, very valuable knowledge. This contrasts somewhat with unit-level tests that might tell you something internal is awry with your application, but its real impact to consumers will still often be unknown. Should you fix it? If there are multiple failures, which are the most important? Unit tests will rarely answer these questions for you.

Of course, you will fix it, or else be unable to confidently release your software–but surely, at times, you will be fixing something that does not matter, or is no longer relevant to your consumers. Unit tests in this way can encourage code rot, making it very difficult to unpick dependencies that are no longer needed. With acceptance tests, you only need to unpick the dependencies in your application, not also in the tests.

## Synergy
Much of this is new to me, and certainly isn't without contention. However, the problems with acceptance-only testing, and specifically the solutions to those problems, indicate certain synergistic practices that may improve its viability:

### Thin Layers
The project we first tried moving to acceptance-only testing on was a very thin layer–a facade over a collection of internal services. It had minimal business logic, and thus few potential execution paths. This certainly allowed us to keep the number of acceptance tests lower than might be expected for a large, complex application, that might branch off into numerous modes of operation. Of course one should probably try to minimise the [cyclomatic complexity] of a code-base anyway, for one's own sanity.

[cyclomatic complexity]:http://en.wikipedia.org/wiki/Cyclomatic_complexity

### Statelessness
If your system maintains a lot of state, acceptance testing can be much harder. This is because you will likely have to set-up much of that state for each test, increasing both developer effort and execution time. Both of which are bad. However, my new favourite thing, sandbox data, may well be your friend in this case.

### Microservices
We have only just begun experimenting with microservices ourselves, however I think it stands to reason that if each application is small overall, then the number of test cases for each will be small as well. This means the whole suite will run faster, and give you more granular feedback. I differentiate microservices from 'thin layers' in that a microservice may well do data access, input parsing, validation, HTTP handling, and a bit of business logic–but over a very narrow domain–i.e. a thin vertical. A thin layer, on the other hand will perform only one kind of function–e.g. HTTP handling–but across multiple facets of the system. If thin layers are the lines of latitude, then microservices can be sections of the lines of longitude.

## Too Short; Read Also
I hope this article has been a little more useful than the previous one. I have tried to explain more specifically what we actually did, from end-to-end, and how we overcame problems along the way. However, I've really only scratched the surface. I will hopefully get the chance flesh out some of the ideas here in the coming months. In the mean time, there are plenty of [books] and [blog posts] on the subject of acceptance testing. In addition, here is a great primer on microservices that's really got me thinking about their utility alongside acceptance-only testing and sandbox data: [http://martinfowler.com/articles/microservices.html](http://martinfowler.com/articles/microservices.html)

[books]:http://www.shino.de/2012/07/02/atdd-by-example/
[blog posts]:http://jonkruger.com/blog/2012/02/20/when-acceptance-tests-are-better-than-unit-tests/

Thanks for reading :)

