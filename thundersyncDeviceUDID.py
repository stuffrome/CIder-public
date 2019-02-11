import sys
from cbrxapi import cbrxapi

result = cbrxapi.cbrx_discover("local")
if result==False:
    print "No Cambrionix unit found."
    sys.exit(0)

unitId = result[0]
handle = cbrxapi.cbrx_connection_open(unitId)

for i in range(1, 17):
    serial = cbrxapi.cbrx_connection_get(handle, "Port." +  str(i) + ".SerialNumber")
    if serial != "" :
        output = str(i) + ":" + str(serial)
        print output

cbrxapi.cbrx_connection_close(handle)
