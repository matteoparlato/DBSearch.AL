report 50100 "DB Search"
{
    UsageCategory = None;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Field; Field)
        {
            trigger OnAfterGetRecord()
            begin
                FindSearchValues();
                CurrReport.Break();
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
            Field.SETFILTER(Type, '%1|%2', Field.Type::Code, Field.Type::Text);
            Field.SETRANGE(Class, Field.Class::Normal);
            Field.SETRANGE(Enabled, TRUE);
            field.SetFilter(ObsoleteState, '%1|%2', Field.ObsoleteState::No, Field.ObsoleteState::Pending);
            Field.SETFILTER(Len, '>=10');
            Field.SETFILTER(TableNo, '(<5340|>5372)&(<6701|>6721)&(<18008020|>18008035)');

            Tip.Message := 'Tip: You can use special symbols (or operators) to further filter the results.';
            Tip.Scope := NotificationScope::LocalScope;
            Tip.Send();
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = Action::OK then
                CheckPassword();
        end;
    }

    [NonDebuggable]
    local procedure CheckPassword()
    var
        Text001Txt: TextConst ENU = 'The specified password is not correct.', ITA = 'La password specificata non è corretta';
    begin
        if Password <> 'a8a0c8e9-bdc8-4719-9e3b-3114328830af' then
            Error(Text001Txt);
    end;

    local procedure FindSearchValues()
    var
        LField: Record Field;
        DBSearch: Record "DB Search";
        RecRef: RecordRef;
        FldRed: FieldRef;
        NextEntryNo: Integer;
        ProgressDialog: Dialog;
    begin
        LField.CopyFilters(Field);
        if DBSearch.FindLast() then
            NextEntryNo := DBSearch."Entry No." + 10000
        else
            NextEntryNo := 0;

        ProgressDialog.OPEN('Searching in table: ############1', LField.TableNo);

        if LField.GetFilter(TableNo) = '' then
            LField.SetFilter(TableNo, '1..1000000000');
        LField.SetRange(Enabled, true);
        LField.SetRange(ObsoleteState, LField.ObsoleteState::No);

        if LField.FindFirst() then
            repeat
                if LField.TableNo <> DATABASE::"DB Search" then begin
                    RecRef.Open(LField.TableNo);

                    ProgressDialog.Update(1, LField.TableNo);

                    FldRed := RecRef.Field(LField."No.");
                    FldRed.SetFilter(Pattern);
                    if RecRef.FindFirst() then
                        repeat
                            FldRed := RecRef.Field(LField."No.");

                            NextEntryNo += 10000;

                            DBSearch.Init();
                            DBSearch."Entry No." := NextEntryNo;
                            DBSearch."Record ID" := RecRef.RecordId;
                            DBSearch."Table No." := LField.TableNo;
                            DBSearch."Table Name" := LField.TableName;
                            DBSearch."Field No." := LField."No.";
                            DBSearch."Field Name" := LField.FieldName;
                            Evaluate(DBSearch."Current Value", FldRed.Value);
                            DBSearch."Correct Value" := DBSearch."Current Value";

                            DBSearch.Insert();
                        until RecRef.Next() = 0;
                    RecRef.Close();
                end;
            until LField.Next() = 0;
        ProgressDialog.Close();
    end;

    var
        Pattern: Text[1024];
        Password: Text[36];
}