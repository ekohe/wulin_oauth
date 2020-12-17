// Toolbar Item 'Add Detail' for detail grid

WulinMaster.actions.CreateNewUser = $.extend(
  {},
  WulinMaster.actions.BaseAction,
  {
    name: "create_new_user",

    handler: function (e) {
      self = this;
      // what I want is not the invite_user grid, but users gird
      // var grid = this.getGrid();
      var gridName = $("body").find(".grid_container").attr("name");
      console.log("gridName", gridName);
      var grid = gridManager.getGrid(gridName);

      var createNewUserForm = `
      <div id="create_new_user">
        <div class="field">
          <label for="email">Email</label>
          <input type="text" id="email" name="order[email]">
        </div>
      </div>
    `;

      var $createUserContainer = Ui.baseModal({
        onOpenEnd: function (modal, trigger) {
          $(modal)
            .find(".modal-content")
            .append($("<h5/>").text("Create new user"))
            .append(createNewUserForm);
        },
      })
        .width(500)
        .height(250);

      var $modalFooter = Ui.modalFooter("Send welcome email").appendTo(
        $createUserContainer
      );
      $modalFooter
        .find(".confirm-btn")
        .off("click")
        .on("click", function () {
          var email = $createUserContainer.find(".field #email").val();

          if (!self.validateEmail(email)) {
            displayErrorMessage(
              "You have entered an invalid email address. Please check again!"
            );
            return;
          }

          self.createNewUser(grid, email);
          // close create_new_user popup
          $createUserContainer.modal("close");
          // close add_user popup
          $("i.modal-close").trigger("click");
        });
    },

    validateEmail: function (email) {
      if (
        /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(
          email
        )
      ) {
        return true;
      }
      return false;
    },

    createNewUser: function (grid, email) {
      self = this;
      let data = { user: { email: email } };
      $.post("/users", data, function (response) {
        if (response.success) {
          self.sendWelcomeEmail(grid, response.id);
        } else {
          displayErrorMessage(response.error_message);
        }
      });
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

WulinMaster.ActionManager.register(WulinMaster.actions.CreateNewUser);
