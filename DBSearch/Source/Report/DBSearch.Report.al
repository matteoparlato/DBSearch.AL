report 50100 "DB Search"
{
    UsageCategory = None;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Field; Field)
        {
            RequestFilterFields = Type, Len, TableNo, FieldName;

            trigger OnPreDataItem()
            begin
                DBSearch.Reset();
                DBSearch.DeleteAll();
                NextEntryNo := 0;

                ProgressDialog.OPEN('Searching in table: ############1', TableNo);

                if GetFilter(TableNo) = '' then
                    SetFilter(TableNo, '1..1000000000');

                SetRange(Enabled, true);
                SetRange(Class, Class::Normal);
                SetRange(ObsoleteState, ObsoleteState::No);
            end;

            trigger OnAfterGetRecord()
            var
                RecRef: RecordRef;
                FldRed: FieldRef;
            begin
                if TableNo <> DATABASE::"DB Search" then begin
                    RecRef.Open(TableNo);

                    ProgressDialog.Update(1, TableNo);

                    FldRed := RecRef.Field("No.");
                    FldRed.SetFilter(Pattern);
                    if RecRef.FindFirst() then
                        repeat
                            FldRed := RecRef.Field("No.");

                            NextEntryNo += 10000;

                            DBSearch.Init();
                            DBSearch."Entry No." := NextEntryNo;
                            DBSearch."Record ID" := RecRef.RecordId;
                            DBSearch."Table No." := TableNo;
                            DBSearch."Table Name" := TableName;
                            DBSearch."Field No." := "No.";
                            DBSearch."Field Name" := FieldName;
                            Evaluate(DBSearch."Current Value", Format(FldRed.Value));
                            if NewValue <> '' then
                                DBSearch."Correct Value" := CopyStr(NewValue, 1, 2048)
                            else
                                DBSearch."Correct Value" := DBSearch."Current Value";

                            DBSearch.Insert();
                        until RecRef.Next() = 0;
                    RecRef.Close();
                end;
            end;

            trigger OnPostDataItem()
            begin
                ProgressDialog.Close();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(SearchPattern; Pattern)
                    {
                        Caption = 'Text to search';
                        ToolTip = 'The value to search in tables.';
                        ApplicationArea = All;
                    }
                    field(NewFieldValue; NewValue)
                    {
                        Caption = 'New field value';
                        ToolTip = 'The new value of the found fields.';
                        ApplicationArea = All;
                    }
                    field(UnlockPassword; Password)
                    {
                        Caption = 'Password';
                        ToolTip = 'The password to unlock the report execution.';
                        ApplicationArea = All;
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            Tip: Notification;
        begin
            Tip.Message := 'Tip: You can use special symbols (or operators) to further filter the results.';
            Tip.Scope := NotificationScope::LocalScope;
            Tip.Send();
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            Fields2: Record Field;
            MinLength: Integer;
            TypeFilter: Text;
        begin
            if CloseAction = Action::OK then begin
                CheckPassword();

                // Type filter is mandatory
                if Field.GetFilter(Type) = '' then
                    Field.TestField(Type);

                // Len filter is mandatory with Code or Text Type
                TypeFilter := Field.GetFilter(Type);
                if TypeFilter.Contains('Code') or TypeFilter.Contains('Text') then
                    if (Field.GetFilter(Len) = '') then begin
                        Fields2.Reset();
                        Fields2.CopyFilters(Field);
                        if Fields2.FindFirst() then begin
                            MinLength := Fields2.Len;
                            repeat
                                if Fields2.Len < MinLength then
                                    MinLength := Fields2.len;
                            until Fields2.Next() = 0;
                        end;
                        Field.SetFilter(Len, '>=%1', MinLength);
                    end;
            end;
        end;
    }

    [NonDebuggable]
    local procedure CheckPassword()
    var
        Text001Txt: Label 'The specified password is not correct.';
    begin
        if Password <> 'a8a0c8e9-bdc8-4719-9e3b-3114328830af' then
            Error(Text001Txt);
    end;

    var
        DBSearch: Record "DB Search";
        Pattern: Text;
        NewValue: Text;
        Password: Text;
        NextEntryNo: Integer;
        ProgressDialog: Dialog;
}