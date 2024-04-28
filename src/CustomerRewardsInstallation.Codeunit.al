codeunit 50100 "Customer Rewards Installation"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany();
    var
        myAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(myAppInfo);

        if myAppInfo.DataVersion = Version.Create(0, 0, 0, 0) then // a DataVersion of 0.0.0.0 indicates a fresh install
            HandleFreshInstall()
        else
            HandleReinstall();
    end;

    local procedure HandleFreshInstall();
    begin
        SetDefaultCustomerRewardsExtMgtCodeunit();
        InsertDefaultRewardLevels();
        InitRewardsForExistingCustomers();
    end;

    local procedure HandleReinstall();
    begin
        // Do work needed when reinstalling the same version of this extension back on this tenant.
        // Some possible usages:
        // - Service callback/telemetry indicating that extension was reinstalled
        // - Data 'patchup' work, for example, detecting if new 'base' records have been changed while you have been working 'offline'.
        // - Set up 'welcome back' messaging for next user access.
    end;

    local procedure InsertRewardLevel(level: Text[20]; minPoints: Integer);
    var
        RewardLevel: Record "Reward Level";
    begin
        Clear(RewardLevel);
        RewardLevel.Level := level;
        RewardLevel."Minimum Reward Points" := minPoints;
        RewardLevel.Insert();
    end;

    procedure SetDefaultCustomerRewardsExtMgtCodeunit();
    var
        CustomerRewardsMgtSetup: Record "Customer Rewards Mgt Setup";
    begin
        CustomerRewardsMgtSetup.DeleteAll();
        CustomerRewardsMgtSetup.Init();
        CustomerRewardsMgtSetup."Cust. Rew. Ext. Mgt. Cod. ID" := Codeunit::"Customer Rewards Ext Mgt";
        CustomerRewardsMgtSetup.Insert();
    end;

    procedure InsertDefaultRewardLevels();
    var
        RewardLevels: Record "Reward Level";
    begin
        Clear(RewardLevels);
        if not RewardLevels.IsEmpty then
            exit;
        InsertRewardLevel('Bronze', 10);
        InsertRewardLevel('Silver', 20);
        InsertRewardLevel('Gold', 30);
        InsertRewardLevel('Platinum', 40);
    end;

    local procedure InitRewardsForExistingCustomers();
    var
        Customer: record Customer;
        SalesHeader: Record "Sales Header";
    begin
        Clear(SalesHeader);
        SalesHeader.SetCurrentKey("Sell-to Customer No.");
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        if SalesHeader.FindSet() then
            repeat
                if not Customer.get(SalesHeader."Sell-to Customer No.") then
                    exit;
                Customer.RewardPoints += 1;
                Customer.Modify();
            until SalesHeader.Next() = 0;
    end;
}