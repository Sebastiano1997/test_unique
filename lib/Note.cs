public class HtmlClass
{
    public HtmlClass(
        Func<string, List<HtmlItem>> getList,
        Func<HtmlItem, HtmlItem> getTyped
        )
    {
        getBodyList = (html) =>
        {
            var list = getList(html);
            for (int i = 0; i < list.Count; i++)
            {
                HtmlItem item = list[i];
                list[i] = getTyped(item);
            }
            return list;
        };
    }

    // + main
    public Func<string, List<HtmlItem>> getBodyList;
    public Func<List<HtmlItem>, List<HtmlItem>> getCheckList;

    public List<HtmlItem> List;
    public void Run()
    {
        string html = "";
        List = getBodyList(html);
        List = getCheckList(List);
        // ...
    }

}
public class HtmlItem
{
    public List<string> listValue;
    public string node;

    public Dictionary<string, object> dicValueType;
}
