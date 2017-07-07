import XMonad
import XMonad.Config.Xfce

import XMonad.Prompt
import XMonad.Prompt.RunOrRaise (runOrRaisePrompt)

import XMonad.Actions.CycleWS

import System.IO
import System.Exit

import XMonad.Util.Run
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Gaps
import XMonad.Layout.Grid
import XMonad.Layout.Circle
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral

import qualified Data.Map as M
import qualified XMonad.StackSet as W
import XMonad.Layout.IndependentScreens

modMask' :: KeyMask
modMask' = mod4Mask

-- Define Terminal:
myTerminal  = "termite"

-- Dzen/Conky:
myXmonadBar = "dzen2 -x '1920' -y '2136' -h '24' -w '1920' -ta 'l' -fg '#A6E22E' -bg '#000000'"
myStatusBar = "conky -c /usr/local/etc/conky/ | dzen2 -x '3840' -y '2136' -w '1920' -h '24' -ta 'r' -bg '#000000' -fg '#A6E22E' "
myBitmapsDir = "/home/lordink/dzen2"
myLayout = smartSpacing 5 $  gaps[(D,24)] $ ThreeCol 1 (3/100) (1/2) ||| ThreeColMid 1 (3/100) (1/2) ||| Circle ||| Grid ||| spiral (toRational (2/(1+sqrt(5)::Double))) ||| Full
myManageHook = composeAll $
    [ isDialog  --> doFloat ]

main = do 
    dzenLeftBar <- spawnPipe myXmonadBar
    dzenRightBar <- spawnPipe myStatusBar
    xmonad $ xfceConfig
	{ modMask             = modMask'
	, borderWidth 	      = 2
    , focusedBorderColor  = "#A6E22E"
    , normalBorderColor   = "#000000"
	, keys                = keys'
    , logHook             = myLogHook dzenLeftBar >> fadeInactiveLogHook 0xdddddddd
	, terminal 	      = myTerminal
	, layoutHook          = myLayout
    , manageHook          = myManageHook
    , workspaces          = withScreens 3 ["General", "Work", "Email", "Misc" ]
}

-- Color names are easier to remember:
colorOrange         = "#FD971F"
colorDarkGray       = "#1B1D1E"
colorPink           = "#F92672"
colorGreen          = "#A6E22E"
colorBlue           = "#66D9EF"
colorYellow         = "#E6DB74"
colorWhite          = "#CCCCC6"
 
colorNormalBorder   = "#CCCCC6"
colorFocusedBorder  = "#A6E22E"

-- Fonts configuration:
barFont  = "inconsolata"
barXFont = "inconsolata:size=12"
xftFont = "xft: inconsolata-14"

-- Prompt Config {{{
mXPConfig :: XPConfig
mXPConfig =
    defaultXPConfig { font                  = barFont
                    , bgColor               = colorDarkGray
                    , fgColor               = colorGreen
                    , bgHLight              = colorGreen
                    , fgHLight              = colorDarkGray
                    , promptBorderWidth     = 0
                    , height                = 14
                    , historyFilter         = deleteConsecutive
                    }

-- Run or Raise Menu
largeXPConfig :: XPConfig
largeXPConfig = mXPConfig
                { font = xftFont
                , height = 22
                }

--Bar
myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ defaultPP
    {
        ppCurrent           =   dzenColor "#ebac54" "#000000" . pad
      , ppVisible           =   dzenColor "#a6e22e" "#000000" . pad -- #1B1D1E
      , ppHidden            =   dzenColor "00fafa" "#000000" . pad
      , ppHiddenNoWindows   =   dzenColor "#7b7b7b" "#000000" . pad
      , ppUrgent            =   dzenColor "#ff0000" "#000000" . pad
      , ppWsSep             =   " "
      , ppSep               =   "  |  "
      , ppLayout            =   dzenColor "#ebac54" "#000000" .
                                (\x -> case x of
                                    "ResizableTall"             ->      "^i(" ++ myBitmapsDir ++ "/tall.xbm)"
                                    "Mirror ResizableTall"      ->      "^i(" ++ myBitmapsDir ++ "/mtall.xbm)"
                                    "Full"                      ->      "^i(" ++ myBitmapsDir ++ "/full.xbm)"
                                    "Simple Float"              ->      "~"
                                    _                           ->      x
                                )
      , ppTitle             =   (" " ++) . dzenColor "#a6e22e" "#000000" . dzenEscape
      , ppOutput            =   hPutStrLn h
    }

-- Key mapping -----------------------------------------------------------------/
keys' conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ --generic
      ((modMask,                    xK_p        ), runOrRaisePrompt largeXPConfig)
    , ((modMask .|. shiftMask,      xK_Return   ), spawn $ XMonad.terminal conf)
    , ((modMask .|. shiftMask,      xK_c        ), kill)
      -- layouts
    , ((modMask,                    xK_space    ), sendMessage NextLayout)
    , ((modMask .|. shiftMask,      xK_space    ), setLayout $ XMonad.layoutHook conf) -- reset layout on current desktop to default
    , ((modMask,                    xK_b        ), sendMessage ToggleStruts)
    , ((modMask,                    xK_n        ), refresh)
    -- move focus to next window
    , ((modMask,                    xK_Tab      ), windows W.focusDown)  
    , ((modMask,                    xK_j        ), windows W.focusDown)
    , ((modMask,                    xK_k        ), windows W.focusUp  )

    -- swap the focused window with the next window:
    , ((modMask .|. shiftMask,      xK_j        ), windows W.swapDown)   

    -- swap the focused window with the previous window:
    , ((modMask .|. shiftMask,      xK_k        ), windows W.swapUp)
     
    , ((modMask,                    xK_Return   ), windows W.swapMaster)

    -- Push window back into tiling:
    , ((modMask,                    xK_t        ), withFocused $ windows . W.sink) 

    , ((modMask,                    xK_h        ), sendMessage Shrink)  -- %! Shrink a master area
    , ((modMask,                    xK_l        ), sendMessage Expand)  -- %! Expand a master area
 
    -- %! Increment the number of windows in the master area:
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))

    -- %! Decrement the number of windows in the master area: 
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1))) 
    , ((modMask .|. shiftMask, xK_l),  spawn "xscreensaver-command --lock")

    -- Quit or restart:
    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess)) -- %! Quit xmonad
    , ((modMask              , xK_q     ), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad
    
    -- Run xmessage with a summary of the default keybindings (useful for beginners):
    , ((modMask .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -")) 
    -- repeat the binding for non-American layout keyboards:
    , ((modMask              , xK_question), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [((m .|. modMask, k), windows $ onCurrentScreen f i)
        | (i, k) <- zip (workspaces' conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++
    -- mod-{w,e,r} %! Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r} %! Move client to screen 1, 2, or 3
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
