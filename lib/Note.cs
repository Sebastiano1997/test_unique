
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;

namespace WpfFilterExample
{
    public partial class MainWindow : Window
    {
        private List<Customer> Customers = new();

        private List<FilterItem> Filters = new();

        public MainWindow()
        {
            InitializeComponent();

            LoadData();

            LoadFields();

            LoadOperators();

            LoadCustomers(Customers);
        }

        // ==========================================
        // MODEL
        // ==========================================

        public class Customer
        {
            public Dictionary<string, object> Data { get; set; } = new();
        }

        public class FilterItem
        {
            public string Field { get; set; } = "";
            public string Operator { get; set; } = "";
            public string Value { get; set; } = "";

            public override string ToString()
            {
                return $"{Field} {Operator} {Value}";
            }
        }

        // ==========================================
        // DATI DI ESEMPIO
        // ==========================================

        private void LoadData()
        {
            Customers = new List<Customer>
            {
                new Customer
                {
                    Data = new Dictionary<string, object>
                    {
                        ["Nome"] = "Mario Rossi",
                        ["Città"] = "Milano",
                        ["Importo"] = 1500m,
                        ["Età"] = 35
                    }
                },

                new Customer
                {
                    Data = new Dictionary<string, object>
                    {
                        ["Nome"] = "Luca Bianchi",
                        ["Città"] = "Roma",
                        ["Importo"] = 800m,
                        ["Età"] = 28
                    }
                },

                new Customer
                {
                    Data = new Dictionary<string, object>
                    {
                        ["Nome"] = "Anna Neri",
                        ["Città"] = "Torino",
                        ["Importo"] = 2200m,
                        ["Età"] = 42
                    }
                },

                new Customer
                {
                    Data = new Dictionary<string, object>
                    {
                        ["Nome"] = "Giuseppe Verdi",
                        ["Città"] = "Milano",
                        ["Importo"] = 3000m,
                        ["Età"] = 50
                    }
                }
            };
        }

        // ==========================================
        // POPOLAMENTO CAMPI
        // ==========================================

        private void LoadFields()
        {
            FieldCombo.Items.Clear();

            var fields = Customers
                .SelectMany(c => c.Data.Keys)
                .Distinct()
                .ToList();

            foreach (var field in fields)
            {
                FieldCombo.Items.Add(new ComboBoxItem
                {
                    Content = field
                });
            }

            if (FieldCombo.Items.Count > 0)
                FieldCombo.SelectedIndex = 0;
        }

        // ==========================================
        // POPOLAMENTO OPERATORI
        // ==========================================

        private void LoadOperators()
        {
            OperatorCombo.Items.Clear();

            string[] operators =
            {
                "Contiene",
                "Uguale",
                "Diverso",
                "Maggiore",
                "Minore",
                "Inizia con",
                "Finisce con"
            };

            foreach (var op in operators)
            {
                OperatorCombo.Items.Add(new ComboBoxItem
                {
                    Content = op
                });
            }

            OperatorCombo.SelectedIndex = 0;
        }

        // ==========================================
        // CARICAMENTO DATAGRID
        // ==========================================

        private void LoadCustomers(List<Customer> customers)
        {
            CustomerGrid.Columns.Clear();

            if (Customers.Count == 0)
                return;

            var fields = Customers
                .SelectMany(c => c.Data.Keys)
                .Distinct()
                .ToList();

            foreach (var field in fields)
            {
                CustomerGrid.Columns.Add(new DataGridTextColumn
                {
                    Header = field,

                    Binding = new Binding($"Data[{field}]"),

                    Width = new DataGridLength(
                        1,
                        DataGridLengthUnitType.Star)
                });
            }

            CustomerGrid.ItemsSource = customers;
        }

        // ==========================================
        // AGGIUNTA FILTRO
        // ==========================================

        private void AddFilter_Click(
            object sender,
            RoutedEventArgs e)
        {
            if (FieldCombo.SelectedItem is not ComboBoxItem fieldItem ||
                OperatorCombo.SelectedItem is not ComboBoxItem operatorItem)
                return;

            string field = fieldItem.Content?.ToString() ?? "";
            string op = operatorItem.Content?.ToString() ?? "";
            string value = ValueText.Text.Trim();

            if (string.IsNullOrWhiteSpace(value))
                return;

            Filters.Add(new FilterItem
            {
                Field = field,
                Operator = op,
                Value = value
            });

            RefreshFilterList();

            ValueText.Clear();
        }

        // ==========================================
        // VISUALIZZAZIONE FILTRI
        // ==========================================

        private void RefreshFilterList()
        {
            FilterList.ItemsSource = null;
            FilterList.ItemsSource = Filters;
        }

        // ==========================================
        // ELIMINAZIONE SINGOLO FILTRO
        // ==========================================

        private void DeleteFilter_Click(
            object sender,
            RoutedEventArgs e)
        {
            if (sender is Button button &&
                button.Tag is FilterItem filter)
            {
                Filters.Remove(filter);

                RefreshFilterList();
            }
        }

        // ==========================================
        // APPLICAZIONE FILTRI
        // ==========================================

        private void Apply_Click(
            object sender,
            RoutedEventArgs e)
        {
            var result = Customers
                .Where(customer =>
                    Filters.All(filter =>
                        EvaluateFilter(customer, filter)))
                .ToList();

            CustomerGrid.ItemsSource = result;
        }

        // ==========================================
        // VALUTAZIONE FILTRO
        // ==========================================

        private bool EvaluateFilter(
            Customer customer,
            FilterItem filter)
        {
            if (!customer.Data.TryGetValue(
                filter.Field, out object? data))
                return false;

            string actual = data?.ToString() ?? "";
            string expected = filter.Value;

            switch (filter.Operator)
            {
                case "Contiene":
                    return actual.Contains(
                        expected,
                        StringComparison.OrdinalIgnoreCase);

                case "Uguale":
                    return string.Equals(
                        actual,
                        expected,
                        StringComparison.OrdinalIgnoreCase);

                case "Diverso":
                    return !string.Equals(
                        actual,
                        expected,
                        StringComparison.OrdinalIgnoreCase);

                case "Inizia con":
                    return actual.StartsWith(
                        expected,
                        StringComparison.OrdinalIgnoreCase);

                case "Finisce con":
                    return actual.EndsWith(
                        expected,
                        StringComparison.OrdinalIgnoreCase);

                case "Maggiore":
                    return CompareValues(data, expected) > 0;

                case "Minore":
                    return CompareValues(data, expected) < 0;

                default:
                    return false;
            }
        }

        // ==========================================
        // CONFRONTO VALORI NUMERICI
        // ==========================================

        private int CompareValues(
            object actual,
            string expected)
        {
            if (actual is IConvertible &&
                decimal.TryParse(
                    expected,
                    System.Globalization.NumberStyles.Any,
                    System.Globalization.CultureInfo.CurrentCulture,
                    out decimal expectedNumber))
            {
                decimal actualNumber = Convert.ToDecimal(actual);

                return actualNumber.CompareTo(expectedNumber);
            }

            return string.Compare(
                actual.ToString(),
                expected,
                StringComparison.OrdinalIgnoreCase);
        }

        // ==========================================
        // RESET FILTRI
        // ==========================================

        private void Reset_Click(
            object sender,
            RoutedEventArgs e)
        {
            Filters.Clear();

            RefreshFilterList();

            CustomerGrid.ItemsSource = Customers;
        }
    }
}
