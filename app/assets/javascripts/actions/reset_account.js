// Toolbar Item 'Reset Account' for user grid

WulinMaster.actions.ResetAccount = $.extend(
  {},
  WulinMaster.actions.BaseAction,
  window.useAction(({ sendWelcomeEmail }) => ({
    name: "reset_account",
    // Toolbar Item 'Reset Account'

    handler: function () {
      var grid = this.getGrid();
      if (grid.screen === "MasterUserDetailRoleScreen") {
        var ids = grid.getSelectedIds();
        if (ids.length === 1) {
          sendWelcomeEmail(grid, ids[0]);
        } else {
          displayErrorMessage("Please select a record.");
        }
      } else {
        displayErrorMessage("Please make sure you are in the right page");
      }
    },
  }))
);

WulinMaster.ActionManager.register(WulinMaster.actions.ResetAccount);
