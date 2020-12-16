// Toolbar Item 'Add Detail' for detail grid

WulinMaster.actions.CreateNewUser = $.extend(
  {},
  WulinMaster.actions.BaseAction,
  {
    name: "create_new_user",

    handler: function (e) {
      self = this;
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
      }).width(500);

      var $modalFooter = Ui.modalFooter("Send welcome email").appendTo(
        $createUserContainer
      );
      $modalFooter.find(".confirm-btn").on("click", function () {
        var email = $createUserContainer.find(".field #email").val();

        if (!self.validateEmail(email)) {
          displayErrorMessage(
            "You have entered an invalid email address. Please check again!"
          );
          return;
        }

        // TODO sen welcome email
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
  }
);

WulinMaster.ActionManager.register(WulinMaster.actions.CreateNewUser);
