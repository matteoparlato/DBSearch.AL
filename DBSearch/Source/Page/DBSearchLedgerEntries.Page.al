page 50101 "DBSearch Ledger Entries"
{
    UsageCategory = None;
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
                    ToolTip = 'The entry number';
                    ApplicationArea = All;
                }
                field("Operation DateTime"; "Operation DateTime")
                {
                    ToolTip = 'The DateTime when the operation was executed';
                    ApplicationArea = All;
                }
                field("Operation Executed By"; "Operation Executed By")
                {
                    ToolTip = 'The UserId who executed the operation';
                    ApplicationArea = All;
                }
                field("Operation Description"; "Operation Type")
                {
                    ToolTip = 'The type of the operation executed';
                    StyleExpr = StyleExpression;
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
                    ToolTip = 'The old value of the field';
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
            action(Restore)
            {
                ApplicationArea = All;
                Image = Restore;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Enabled = CanRestore;
                PromotedCategory = Process;
                ToolTip = 'Restore the previous field value of the selected row';

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
                ToolTip = 'Open the record of the selected row';

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
