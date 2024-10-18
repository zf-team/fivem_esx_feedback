# fivem_esx_feedback

**❗️❗️ONLY AVAIBLE IN GERMAN FOR THE MOMENT❗️❗️**

## Overview

`fivem_esx_feedback` is a Lua-based feedback system for the ESX framework in FiveM. This system allows players to submit feedback directly in-game, which can then be reviewed by the server administrators.

## Features

- In-game feedback submission.
- Admin panel to review and manage feedback.
- Easy integration with existing ESX servers.
- Configurable settings.

## Installation

1. Clone the repository to your `resources` folder:
    ```sh
    git clone https://github.com/zf-team/fivem_esx_feedback.git
    ```

2. Go to your database <br>
   -> Press import <br>
   -> Insert the `new_table.sql` file <br>
   -> Press save <br>
   => It should create a new table named `checked_users` <br>

4. Add `fivem_esx_feedback` to your server configuration file (`server.cfg`):
    ```plaintext
    ensure fivem_esx_feedback
    ```

5. Restart your server or start the resource manually using the console:
    ```plaintext
    start fivem_esx_feedback
    ```

## Configuration

The Configuration step is **VERY** important for this code. Please make this changed before you run the code:

```lua
Config.LocalFilePath = ''  The path is usually found in the <server_folder>\txData\default\data. There should be a file named playersDB.json. PUT THE PATH OF THAT FILE IN THERE

----
...
----

Config.DiscordWebhook = {
  Url='your_discord_webhook_url',
  Name='name_of_webhook'
}
```

## Usage

To check the user admins can type `/checked <id>`. Admins can see the feedback requests in the discord channel they linked the webhook with.
With `/outfit` the admins can toggle the outfit set in the config file to meet up with the person in-game and give more life in the RP.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or support, please open an issue on the GitHub repository or contact the project maintainers.

