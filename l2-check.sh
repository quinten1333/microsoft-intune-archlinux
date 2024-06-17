#!/bin/bash

function askFix() { # question, fix code
  read -p "$1(Y/n)" answer

  if [[ "$answer" == "n" ]]; then
    echo "Okey, run \"$1\" to fix"
  else
    $2
    echo "Fixed"
    echo ""
  fi
}

# intune-agent
if [[ -z $(systemctl status --user intune-agent.timer | grep "Active: active") ]]; then
  echo "intune-agent.timer not running!"
  askFix "Enable it?" "systemctl enable --user --now intune-agent.timer"
else
  echo "intune-agent.timer:                         OK"
fi

if [[ -z $(systemctl status --user intune-agent.service | grep "(code=exited, status=0/SUCCESS)") ]]; then
  echo "intune-agent.service last run did not finish succesfully"
  askFix "Retry running it?" "systemctl start --user intune-agent.service"
  systemctl status --user intune-agent.service
else
  echo "intune-agent.service last exit code:        OK"
fi

# intune-daemon.socket
if [[ -z $(systemctl status intune-daemon.socket | grep "Active: active (listening)") ]]; then
  echo "intune-daemon.socket not running!"
  askFix "Enable it?" "systemctl enable intune-daemon.socket"
else
  echo "intune-daemon.socket:                       OK"
fi

# microsoft-identity-broker.service
if [[ -z $(systemctl status --user microsoft-identity-broker.service | grep "Active: active") ]]; then
  echo "microsoft-identity-broker.service not running!"
  askFix "Enable it?" "systemctl enable --user microsoft-identity-broker.service"
else
  echo "microsoft-identity-broker.service:          OK"
fi

# microsoft-identity-device-broker.service
if [[ -z $(systemctl status microsoft-identity-device-broker.service | grep "Active: active") ]]; then
  echo "microsoft-identity-device-broker.service not running!"
  askFix "Enable it?" "systemctl enable microsoft-identity-device-broker.service"
else
  echo "microsoft-identity-device-broker.service:   OK"
fi

# mdatp
if [[ -z $(systemctl status mdatp | grep "Active: active") ]]; then
  echo "mdatp not running!"
  askFix "Enable it?" "systemctl enable mdatp"
else
  echo "mdatp:                                      OK"
fi
