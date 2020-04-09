page 50101 "DBSearch Ledger Entries"
{
    PageType = Worksheet;
    SourceTable = "DB Search Ledger Entry";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    PromotedActionCategories = 'Process';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Operation DateTime"; "Operation DateTime")
                {
                    ApplicationArea = All;
                }
                field("Operation Executed By"; "Operation Executed By")
                {
                    ApplicationArea = All;
                }
                field("Operation Description"; "Operation Type")
                {
                    StyleExpr = StyleExpression;
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
            action(Restore)
            {
                ApplicationArea = All;
                Image = Restore;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Enabled = CanRestore;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    DBSearchFunctions.RestoreValue(Rec);
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
                Enabled = CanOpen;

                trigger OnAction()
                begin
                    DBSearchFunctions.ShowRecord("Record ID");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CanOpen := true;
        CanRestore := false;
        case "Operation Type" of
            "Operation Type"::Deleted:
                begin
                    StyleExpression := 'Unfavorable';
                    CanOpen := false;
                end;
            "Operation Type"::Modified:
                begin
                    StyleExpression := 'Unfavorable';
                    CanRestore := true;
                end else
                        StyleExpression := 'Favorable';
        end;
    end;

    var
        CanOpen: Boolean;
        CanRestore: Boolean;
        DBSearchFunctions: Codeunit "DB Search Functions";
        StyleExpression: Text;
}
