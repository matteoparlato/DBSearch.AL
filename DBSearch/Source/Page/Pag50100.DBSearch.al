page 50100 "DB Search"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DB Search";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("Selected"; "Selected")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Current Value"; "Current Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Correct Value"; "Correct Value")
                {
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

                trigger OnAction()
                begin
                    Page.RunModal(Page::"DBSearch Ledger Entries");
                end;
            }
        }
    }

    var
        DBSearchFunctions: Codeunit "DB Search Functions";
}