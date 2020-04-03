report 50100 "DB Search"
{
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem(DataItemName; Field)
        {

        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(ValueToSearch; ValueToSearch)
                    {
                        ApplicationArea = All;
                    }
                    field(FieldToCorrect; FieldToCorrect)
                    {
                        ApplicationArea = All;
                    }
                    field(CorrectValue; CorrectValue)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        ValueToSearch: Text[1024];
        FieldToCorrect: Text[250];
        CorrectValue: Text[1024];

}