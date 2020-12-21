// Toolbar Item 'Reset Account' for user grid

WulinMaster.actions.ResetAccount = $.extend(
  {},
  WulinMaster.actions.BaseAction,
  {
    name: "reset_account",
    // Toolbar Item 'Reset Account'

    handler: function () {
      var self = this;
      var grid = this.getGrid();

      var ids = grid.getSelectedIds();
      if (ids.length === 1) {
        self.sendWelcomeEmail(grid, ids[0]);
      } else {
        displayErrorMessage("Please select a record.");
      }
    },

    sendWelcomeEmail: function (grid, user_id) {
      $.post(
        `/users/${user_id}/send_mail`,
        { _method: "PUT" },
        function (response) {
          if (response.success) {
            // reload users grid data
            grid.loader.reloadData();
            displayNewNotification("Email successfully sent!");
          } else {
            displayErrorMessage(response.error_message);
          }
        }
      );
    },
  }
);

WulinMaster.ActionManager.register(WulinMaster.actions.ResetAccount);
