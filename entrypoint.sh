#!/bin/bash
set -e

if [ -z "$CRON_SCHEDULE" ]; then
    echo "ERROR: CRON_SCHEDULE is required (e.g. '0 2 * * *')"
    exit 1
fi

if [ ! -f /config/config.json ]; then
    echo "ERROR: /config/config.json not found — mount it at /config/config.json"
    exit 1
fi

cat << 'BANNER'
                                                                       
                          =======     =======                          
                      +============+   ==========                      
                   ==================    ==========+                   
                 =======+        ====         +=======                 
               =======           +===+           +======               
             ======              +===+              ======             
            =====                +===+                =====            
           =====            ==== +===+ ====            =====           
          =====             +====+===+====+             =====          
         =====           ###  ===========  %##           =====         
        =====        %#####%   =========   #######        =====        
        ====       ######        =====        %#####       ====        
       +===+      ###%######%     +==     ###########      +====       
       ====     ####     #######       #######     ####     ====       
       ====    ####          %############          ####    ====       
       ====    #######           #####           %######    ====       
       ====       %######       #######       #######       ====       
       ====        ###%######  #########% %#########        ====       
       +===+       %##    ####### ### #######    ###       +====       
        ====       ###       %##  ###  ##%       ###       ====        
        =====      ###            ###            ###      +====        
         ====      %######        ###        ######%     +====         
                      #######     ###     #######       =====          
            =======++     ####### ### #######%         =====           
            =========         ###########             =====            
            +=======             %###%              =====+             
             =========                           =======               
             === +======+                      =======                 
             ==    +=========+            ==========                   
                      +==========================                      
                          ===================                          
                                                                       
BANNER
echo "docker-volume-backup v${APP_VERSION} starting"
echo "Timezone: ${TZ:-UTC}"
echo "Container time: $(date)"
echo "Schedule: ${CRON_SCHEDULE}"
echo ""
STACK_COUNT=$(jq '.stacks | length' /config/config.json)
STACK_NAMES=$(jq -r '.stacks[].name' /config/config.json | tr '\n' ',' | sed 's/,$//')
echo "Stacks to backup: ${STACK_COUNT} (${STACK_NAMES})"
echo ""

mkdir -p /etc/crontabs
echo "${CRON_SCHEDULE} /bin/bash /usr/local/bin/container-backups.sh /config/config.json >> /proc/1/fd/1 2>&1" \
    > /etc/crontabs/root

exec crond -f