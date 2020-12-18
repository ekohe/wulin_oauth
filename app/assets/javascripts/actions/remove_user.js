// Toolbar Item 'Remove User' for user grid

WulinMaster.actions.RemoveUser = $.extend({}, WulinMaster.actions.BaseAction, {
  name: "remove_user",
  // Toolbar Item 'Remove User'

  handler: function () {
    var grid = this.getGrid();

    var ids = grid.getSelectedIds();
    if (ids.length === 1) {
      this.deleteGridRecords(grid, ids);
      return false;
    } else {
      displayErrorMessage("Please select a record.");
    }
  },
});

WulinMaster.ActionManager.register(WulinMaster.actions.RemoveUser);
