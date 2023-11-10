namespace BgApp.Tests;

public class CounterTests
{
    /// <summary>
    /// Tests that the Counter component increments the count when the button is clicked.
    /// More tests should be added
    /// </summary>
    [Fact]
    public void CounterShouldIncrementWhenClicked()
    {
        // Arrange
        using var ctx = new TestContext();
        var cut = ctx.RenderComponent<Counter>();
        var paraElm = cut.Find("p");

        // Act
        cut.Find("button").Click();

        // Assert
        var paraElmText = paraElm.TextContent;
        paraElmText.MarkupMatches("Current count: 1");
    }
}