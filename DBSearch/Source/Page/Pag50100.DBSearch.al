page 50100 "DB Search"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DB Search";
    InsertAllowed = false;
    DeleteAllowed = true;
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
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Record ID"; "Record ID")
                {
                    ApplicationArea = All;
                }
                field("Current Value"; "Current Value")
                {
                    ApplicationArea = All;
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
                    DBSearch.RunModal();
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
                    DBSearchFunctions.CorrectSearchValues(Rec);
                end;
            }

            action(Delete)
            {
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    DBSearchFunctions.DeleteSearchRecords(Rec);
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
        DBSearch: Report "DB Search";
        DBSearchFunctions: Codeunit "DB Search Functions";
}