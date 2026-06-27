#/bin/bash
    set -e
    URL=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.Tags[].Value == "dev-deploy") | .PublicDnsName')
    echo $URL
    if  [ "$URL"  != "" ]; then
        curl http://$URL:3001/live
        http_code=$(curl -s -o /dev/null -w "%{http_code}" http://$URL:3001/live)
        echo "http_code - $http_code"
        if [ $http_code -eq 200 ]; then
            echo "Application is live"
        else
            echo "Application is Down as status - ${http_code}"
            exit 1
        fi;
    else 
        echo "No server found in AWS"
        exit 1
    fi
                    	