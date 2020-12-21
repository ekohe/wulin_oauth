const actions = {
  sendWelcomeEmail(grid, user_id) {
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
};

window.useAction = (fn) => fn(actions);
