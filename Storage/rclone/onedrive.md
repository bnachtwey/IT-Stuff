# Accessing M$ NoneDrive using rclone

Although there's a fine manual on the [rclone website](https://rclone.org/docs/), I'd like to add some remarks on it:

## Setting up a _new_ remote connection

### Linux (Debian 13)

The setup is quite straight forward as described in the official docs, so I just outline it _step-by-step_

1) start config

   ```bash
   rclone config
   ```
2) select `n` for _new remote_
3) name it, e.g. `OneDrive`
4) select storage type by name `onedrive`

   The numbers are changing in different _rclone_ versions, so using the name is the better approach.

5) enter no `client_id`
6) enter no `client_secret`
7) Selete Region

   - typically it's _1 / Microsoft Cloud Global (global)_ if you use ordinary _M365_
   - _3 / Germany_ did not work, maybe this is used for the _Delos Cloud_ users only?

8) enter no `tennant`
9) skip `advanced config`
10) Answer `Use Webbrowser to authenticate`

    - `Y`es if your system can start a webbrower _and_ you can access `localhost`
   
      skipt next and go to step 18
      
    - `N`o for headless nodes
   
for headless nodes

11) get another Notebook/PC with rclone installed (no MAC!) and run (as suggested)

    ```bash
    rclone authorize onedrive
    ```

    The `rclone` commandline remains open waiting for the token. Do not close!

    > **TIP**
    >
    > although the Docu recommends to have the same version of rclone, I created a token using _rclone 1.60_ and could use it with _rclone 1.71_

for a headless configuration (e.g. servers)

13) a browser window pops up asking to authenticate against M$ online: do so :-)
14) After the browser showing "_Success! All done. Please go back to rclone._" a large text appears in the terminal.
15) As recommended, copy the full token string and enter it to the rclone CLI waiting on your headless node :-)
16) Confirm, you'll keep this config.
17) _rclone_ shows your config.
18) You are ready!

for a local configuration

18) a browser window pops up asking to authenticate against M$ online: do so :-)
19) After the browser showing "_Success! All done. Please go back to rclone._" the token is automatically copied to the config
20) ```bash
    Choose a number from below, or type in your own string value.
    Press Enter for the default (b!OjN4dX1_okmqrMngQdQLXy-vlD2hm7xBtw6DPrjEVP0ye9ieRL9xSpNPmJaFQdxl).
    
    1 / PersonalCacheLibrary (business)
    \ <...>
    2 / Dokumente (business)
    \ <...>
    ```
    chose 2) as 1) shows nothing with any sense.
22) You are ready!



### MacOS (`Darwin Kernel 24.6.0`)

As by default the mac denys accessing your `localhost`, you have to follow the _headless_ approach described above.

## testing the connection

### get configuration

```bash
# rclone config dump
{
    "<MY CONFIG>": {
        "drive_id": "<DRIVE Token>",
        "drive_type": "business",
        "token": "{\"access_token\":\"<T O K E N >\"}",
        "type": "onedrive"
    }
}
```

### `rclone ls` and `rclone lsd`

- list diretories only

  ```bash
  rclone lds <MY CONFIG>:
  ```
  
