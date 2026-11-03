
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Controls;

namespace WpfFilterExample;

public partial class MainWindow : Window
{
    private ObservableCollection<Customer> Customers = new();

    private ObservableCollection<string> Filters = new();

    public MainWindow()
    {
        InitializeComponent();

        updateTable();

    }

    public void updateTable()
    {
        // + list item
        Customers.Clear();

        Customers.Add(new Customer
        {
            Name = "Mario Rossi",
            City = "Milano",
            Amount = 1500,
            Dic = new Dictionary<string, object> {
                {"Name","Mario Rossi" },
                {"City","Milano" },
                {"Amount",1500 },
            }
        });

        Customers.Add(new Customer
        {
            Name = "Luca Bianchi",
            City = "Roma",
            Amount = 800,
            Dic = new Dictionary<string, object> {
                {"Name","Luca Bianchi" },
                {"City","Roma" },
                {"Amount",800 },
            }
        });

        Customers.Add(new Customer
        {
            Name = "Giuseppe Verdi",
            City = "Milano",
            Amount = 2500,
            Dic = new Dictionary<string, object> {
                {"Name","Giuseppe Verdi" },
                {"City","Milano" },
                {"Amount",2500 },
            }
        });

        Customers.Add(new Customer
        {
            Name = "Anna Neri",
            City = "Torino",
            Amount = 1200,
            Dic = new Dictionary<string, object> {
                {"Name","Anna Neri" },
                {"City","Torino" },
                {"Amount",1200 },
            }
        });

        CustomerGrid.ItemsSource = Customers; // todo use it

        // + FieldCombo.Items
        FieldCombo.Items.Clear();
        foreach (string key in Customers.First().Dic.Keys)
        {
            FieldCombo.Items.Add(new ComboBoxItem
            {
                Content = key
            });

        }

        FilterList.ItemsSource = Filters;
    }

    private void AddFilter_Click(object sender, RoutedEventArgs e)
    {
        string field = ((ComboBoxItem)FieldCombo.SelectedItem).Content.ToString()!;
        string op = ((ComboBoxItem)OperatorCombo.SelectedItem).Content.ToString()!;
        string value = ValueText.Text.Trim();

        if (string.IsNullOrWhiteSpace(value))
            return;

        Filters.Add($"{field}|{op}|{value}");

        ValueText.Clear();
    }

    private void Apply_Click(object sender, RoutedEventArgs e)
    {
        var result = Customers.Where(customer =>
        {
            foreach (string filter in Filters)
            {
                var parts = filter.Split('|');

                string field = parts[0];
                string op = parts[1];
                string value = parts[2];

                object valueItem=customer.Dic[field];
                bool isChecked = false;

                if(op=="Contiene")
                {
                    isChecked = valueItem.ToString().Contains(value,
                                StringComparison.OrdinalIgnoreCase);
                }
                else if (op == "Uguale")
                {
                    double.TryParse(valueItem.ToString(), out double valueItemX);
                    double.TryParse(value.ToString(), out double valueX);
                    isChecked = (valueItemX == valueX);
                }
                else if(op == "Maggiore")
                {
                    double.TryParse(valueItem.ToString(),out double valueItemX);
                    double.TryParse(value.ToString(),out double valueX);
                    isChecked = (valueItemX>valueX);
                }
                else if(op == "Minore")
                {
                    double.TryParse(valueItem.ToString(), out double valueItemX);
                    double.TryParse(value.ToString(), out double valueX);
                    isChecked = (valueItemX < valueX);
                }

                if (!isChecked)
                    return false;
            }

            return true;
        }).ToList();

        CustomerGrid.ItemsSource = result;
    }

    private void Reset_Click(object sender, RoutedEventArgs e)
    {
        Filters.Clear();
        CustomerGrid.ItemsSource = Customers;
    }


    private void DeleteFilter_Click(object sender, RoutedEventArgs e)
    {
        if (sender is Button button &&
            button.Tag is string filter)
        {
            Filters.Remove(filter);
        }
    }

}

public class Customer
{
    public string Name { get; set; } = "";
    public string City { get; set; } = "";
    public double Amount { get; set; }

    public Dictionary<string, object> Dic { get; set; } = new Dictionary<string, object>();
}
