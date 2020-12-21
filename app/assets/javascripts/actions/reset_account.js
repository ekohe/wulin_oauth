// Toolbar Item 'Reset Account' for user grid

WulinMaster.actions.ResetAccount = $.extend(
  {},
  WulinMaster.actions.BaseAction,
  {
    name: "reset_account",
    // Toolbar Item 'Reset Account'

    handler: function () {
      alert("1111111");
    },
  }
);

WulinMaster.ActionManager.register(WulinMaster.actions.ResetAccount);
