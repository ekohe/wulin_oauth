// Toolbar Item 'Add Detail' for detail grid

if (typeof(WulinMaster) != 'undefined') {
  WulinMaster.actions.CreateNewUser = $.extend(
    {},
    WulinMaster.actions.BaseAction,
    window.useAction(({ sendWelcomeEmail }) => ({
      name: "create_new_user",

      handler: function (e) {
        self = this;
        // what I want is not the invite_user grid, but users gird
        // var grid = this.getGrid();
        var gridName = $("body").find(".grid_container").attr("name");
        console.log("gridName", gridName);
        var grid = gridManager.getGrid(gridName);

        var createNewUserForm = `
        <div id="create_new_user" class='create_form'>
          <div class='field-line'>
            <div class='field'>
              <div class='input-field input-outlined'>
                <label for="email">Email</label>
                <input type="text" id="email" name="order[email]">
              </div>
            </div>
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
            sendWelcomeEmail(grid, response.id);
          } else {
            displayErrorMessage(response.error_message);
          }
        });
      },
    }))
  );

  WulinMaster.ActionManager.register(WulinMaster.actions.CreateNewUser);
}
