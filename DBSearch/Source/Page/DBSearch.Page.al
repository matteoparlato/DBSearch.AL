page 50100 "DB Search"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DB Search";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    PromotedActionCategories = 'Process';

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("Selected"; "Selected")
                {
                    ToolTip = 'Select the values to correct or delete';
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ToolTip = 'The number of the table';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Table Name"; "Table Name")
                {
                    ToolTip = 'The name of the table';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Field No."; "Field No.")
                {
                    ToolTip = 'The number of the field';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Field Name"; "Field Name")
                {
                    ToolTip = 'The name of the field';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Current Value"; "Current Value")
                {
                    ToolTip = 'The current value of the field';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Correct Value"; "Correct Value")
                {
                    ToolTip = 'The new value of the field';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Search)
            {
                ApplicationArea = All;
                Image = Find;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Search for values in all tables';

                trigger OnAction()
                begin
                    DBSearchFunctions.SearchValues();
                end;
            }

            action(Correct)
            {
                ApplicationArea = All;
                Image = Apply;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Apply the new value to the selected rows';

                trigger OnAction()
                begin
                    DBSearchFunctions.CorrectValues(Rec);
                end;
            }

            action(Delete)
            {
                ApplicationArea = All;
                Image = CancelLine;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Delete the selected records';

                trigger OnAction()
                begin
                    DBSearchFunctions.DeleteRecords(Rec);
                end;
            }

            action(Clear)
            {
                ApplicationArea = All;
                Image = ClearLog;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Clear search result';

                trigger OnAction()
                begin
                    Reset();
                    DeleteAll();
                    CurrPage.Update();
                end;
            }

            action(Show)
            {
                ApplicationArea = All;
                Image = ReviewWorksheet;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Open the record of the selected row.';

                trigger OnAction()
                begin
                    DBSearchFunctions.ShowRecord("Record ID");
                end;
            }

            action(History)
            {
                ApplicationArea = All;
                Image = History;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Show DB Search usage history';

                trigger OnAction()
                begin
                    Page.RunModal(Page::"DBSearch Ledger Entries");
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        Text001Txt: Label 'Clear session results? Other users may apply unwanted chages to data.';
    begin
        Reset();
        if Count() <> 0 then
            if Confirm(Text001Txt) then
                DeleteAll();
    end;

    var
        DBSearchFunctions: Codeunit "DB Search Functions";
}