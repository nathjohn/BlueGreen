namespace BgApp.Tests;

public class CounterTests
{
    /// <summary>
    /// Tests that the Counter component increments the count when the button is clicked.
    /// </summary>
    [Fact]
    public void CounterShouldIncrementWhenClicked()
    {
        // Arrange - Find the counter component
        using var ctx = new TestContext();
        var cut = ctx.RenderComponent<Counter>();
        var paraElm = cut.Find("p");

        // Act - Click the button
        cut.Find("button").Click();

        // Assert - Check that the counter was incremented
        var paraElmText = paraElm.TextContent;
        paraElmText.MarkupMatches("Current count: 1");
    }
}