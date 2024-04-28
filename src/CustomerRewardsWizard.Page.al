page 50100 "Customer Rewards Wizard"
{
    PageType = NavigatePage;
    Caption = 'Customer Rewards assisted setup guide.';

    layout
    {
        area(content)
        {
            group(MediaStandard)
            {
                caption = '';
                Editable = false;
                Visible = TopBannerVisible;

                field("Media Reference"; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = ALl;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FirstPage)
            {
                Caption = '';
                Visible = FirstPageVisible;

                group(Welcome)
                {
                    Caption = 'Welcome';
                    Visible = FirstPageVisible;

                    group(Introduction)
                    {
                        Caption = '';
                        InstructionalText = 'This extension adds a reward system for your customers.';
                        Visible = FirstPageVisible;

                        field(Spacer1; '')
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = false;
                        }
                    }

                    group(Terms)
                    {
                        Caption = 'Terms of Use';
                        Visible = FirstPageVisible;

                        group(Terms1)
                        {
                            Caption = '';
                            InstructionalText = 'By enabling the Customer Rewards extension you agree to our terms of use.';
                        }
                    }

                    group(Terms2)
                    {
                        Caption = '';

                        field(EnableFeature; EnableCustomerRewards)
                        {
                            ApplicationArea = All;
                            MultiLine = true;
                            Editable = true;
                            Caption = 'I understand and accept these terms.';
                            ToolTip = 'Click to confirm: I understand and accept these terms.';

                            trigger OnValidate();
                            begin
                                ShowFirstPage();
                            end;
                        }
                    }
                }
            }

            group(SecondPage)
            {
                Caption = '';
                Visible = SecondPageVisible;

                group(Activation)
                {
                    Caption = 'Activation';
                    Visible = SecondPageVisible;

                    field(Spacer2; '')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                    }

                    group(ActivationMessage)
                    {
                        Caption = '';
                        InstructionalText = 'Enter your 14 digit activation code to continue.';
                        Visible = SecondPageVisible;

                        field(ActivationCode; ActivationCode)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Editable = true;
                        }
                    }
                }
            }

            group(FinalePage)
            {
                Caption = '';
                Visible = FinalPageVisible;

                group(ActivationDone)
                {
                    Caption = 'You''re done!';
                    Visible = FinalPageVisible;

                    group(DoneMessage)
                    {
                        Caption = '';
                        InstructionalText = 'Click Finish to set up your rewards level and start using Customer Rewards.';
                        Visible = FinalPageVisible;
                    }
                }
            }
        }
    }

    // Actions:
    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackEnabled;
                Visible = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }

            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextEnabled;
                Visible = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }

            action(ActionActivate)
            {
                ApplicationArea = All;
                Caption = 'Activate';
                Enabled = ActivateEnabled;
                Visible = ActivateEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction();
                var
                    CustomerRewardsExtMgt: Codeunit "Customer Rewards Ext Mgt";
                begin
                    if ActivationCode = '' then
                        Error('Activation code cannot be blank.');

                    if Text.StrLen(ActivationCode) <> 14 then
                        Error('Activation code must be exactly 14 digits.');

                    if CustomerRewardsExtMgt.ActivateCustomerRewards(ActivationCode) then
                        NextStep(false)
                    else
                        Error('Activation failed. Please check the code you entered.');
                end;
            }

            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinalPageVisible;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction();
                begin
                    FinishAndEnableExtension();
                end;
            }
        }
    }

    // Triggers:
    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        Step := Step::First;
        EnableControls();
    end;

    // Local procedures:
    local procedure ShowFirstPage();
    begin
        FirstPageVisible := true;
        SecondPageVisible := false;
        FinishEnabled := false;
        BackEnabled := false;
        NextEnabled := EnableCustomerRewards;
        ActivateEnabled := false;
    end;

    local procedure ShowSecondPage();
    begin
        FirstPageVisible := false;
        SecondPageVisible := true;
        FinishEnabled := false;
        BackEnabled := true;
        NextEnabled := false;
        ActivateEnabled := true;
    end;

    local procedure ShowFinalPage();
    begin
        FinalPageVisible := true;
        BackEnabled := true;
        NextEnabled := false;
        ActivateEnabled := false;
    end;

    local procedure ResetControls();
    begin
        FinishEnabled := true;
        BackEnabled := true;
        NextEnabled := true;
        ActivateEnabled := true;
        FirstPageVisible := false;
        SecondPageVisible := false;
        FinalPageVisible := false;
    end;

    local procedure EnableControls();
    begin
        ResetControls();
        case Step of
            Step::First:
                ShowFirstPage();
            Step::Second:
                ShowSecondPage();
            Step::Finish:
                ShowFinalPage();
        end;
    end;

    local procedure NextStep(IsBack: Boolean);
    begin
        if IsBack then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure FinishAndEnableExtension();
    var
        CustomerRewardsExtMgt: Codeunit "Customer Rewards Ext Mgt";
        GuidedExperience: Codeunit "Guided Experience";
        Info: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Info);
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Customer Rewards Wizard");
        CurrPage.Close();
        CustomerRewardsExtMgt.OpenRewardsLevelPage();
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType)) then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") then
                TopBannerVisible := MediaResourcesStandard."Media Reference".HasValue;
    end;

    // Variables:
    var
        TopBannerVisible: Boolean;
        MediaResourcesStandard: Record "Media Resources";
        FirstPageVisible: Boolean;
        SecondPageVisible: Boolean;
        FinishEnabled: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        ActivateEnabled: Boolean;
        EnableCustomerRewards: Boolean;
        ActivationCode: Text;
        FinalPageVisible: Boolean;
        Step: Option First,Second,Finish;
        MediaRepositoryStandard: Record "Media Repository";
}