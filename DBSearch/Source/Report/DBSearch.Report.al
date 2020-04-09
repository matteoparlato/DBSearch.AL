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
        rrTab: RecordRef;
        rrSearchValuesFieldTmp: RecordRef;
        frFieldEntryNo: FieldRef;
        frFieldRecordID: FieldRef;
        frFieldTabNo: FieldRef;
        frTableName: FieldRef;
        frFieldFieldNo: FieldRef;
        frFieldName: FieldRef;
        frFieldCurrValue: FieldRef;
        frFieldNewValue: FieldRef;
        frField: FieldRef;
        NextEntryNo: Integer;
        ProgressDialog: Dialog;
        txtOldValue: Text;
    begin
        LField.CopyFilters(Field);
        if DBSearch.FindLast() then
            NextEntryNo := DBSearch."Entry No." + 10000
        else
            NextEntryNo := 0;

        ProgressDialog.OPEN('Searching in table: ############1', LField.TableNo);

        rrSearchValuesFieldTmp.Open(DATABASE::"DB Search");
        frFieldEntryNo := rrSearchValuesFieldTmp.Field(1);
        frFieldRecordID := rrSearchValuesFieldTmp.Field(2);
        frFieldTabNo := rrSearchValuesFieldTmp.Field(3);
        frTableName := rrSearchValuesFieldTmp.Field(4);
        frFieldFieldNo := rrSearchValuesFieldTmp.Field(5);
        frFieldName := rrSearchValuesFieldTmp.Field(6);
        frFieldCurrValue := rrSearchValuesFieldTmp.Field(7);
        frFieldNewValue := rrSearchValuesFieldTmp.Field(8);

        if LField.GetFilter(TableNo) = '' then
            LField.SetFilter(TableNo, '1..1000000000');
        LField.SetRange(Enabled, true);
        LField.SetRange(ObsoleteState, LField.ObsoleteState::No);

        if LField.FindFirst() then
            repeat
                if LField.TableNo <> DATABASE::"DB Search" then begin
                    rrTab.Open(LField.TableNo);

                    ProgressDialog.Update(1, LField.TableNo);

                    frField := rrTab.Field(LField."No.");
                    frField.SetFilter(Pattern);
                    if rrTab.FindFirst() then
                        repeat
                            frField := rrTab.Field(LField."No.");
                            txtOldValue := Format(frField.Value);
                            frFieldTabNo.Value(LField.TableNo);
                            frTableName.Value(LField.TableName);
                            frFieldFieldNo.Value(LField."No.");
                            frFieldName.Value(LField.FieldName);
                            EVALUATE(frFieldCurrValue, txtOldValue);
                            frFieldRecordID.Value(rrTab.RecordId);
                            EVALUATE(frFieldNewValue, txtOldValue);

                            NextEntryNo += 10000;
                            frFieldEntryNo.Value(NextEntryNo);
                            rrSearchValuesFieldTmp.Insert();
                        until rrTab.Next() = 0;
                    rrTab.Close();
                end;
            until LField.Next() = 0;
        ProgressDialog.Close();
        rrSearchValuesFieldTmp.Close();
    end;

    var
        Pattern: Text[1024];
        Password: Text[36];
}