import os
import gzip
import netCDF4



sStaticFolder = "/mnt/nas/IT-WATER/S3M_static/present"
sTemplatePath = "./s3m-runner/app_runner_workflow_s3m_template.json"
sOutputFolder = "./s3m-runner/config/present"

asStaticFiles = []
for root, dirs, files in os.walk(sStaticFolder):
    for sStaticFile in files:
        asStaticFiles.append(os.path.relpath(os.path.join(root, sStaticFile), sStaticFolder))

for sStaticFile in asStaticFiles:
    sDomainName = os.path.basename(os.path.dirname(sStaticFile))
    if sStaticFile.endswith(".nc.gz"):
        with gzip.open(os.path.join(sStaticFolder, sStaticFile), 'rb') as gzipped_file:
            with netCDF4.Dataset('inmemory.nc', memory=gzipped_file.read()) as nc:
                # Extract desired information from the netCDF file
                aoGobalAttributes = {attr: getattr(nc, attr) for attr in nc.ncattrs()}

                # Write the extracted information to the output file
                # Read the template file
                
                with open(sTemplatePath, 'r') as oTemplateFile:
                    sTemplateConfig = oTemplateFile.read()

                # Replace placeholders with global attribute values
                for attr, value in aoGobalAttributes.items():
                    sPlaceholder = f"%{attr}%"
                    if isinstance(value, float) and value.is_integer():
                        value = int(value)  # Convert to integer if it's a float ending with .0
                    sTemplateConfig = sTemplateConfig.replace(sPlaceholder, str(value))

                # Save the modified content to a new file
                sConfigFile = os.path.join(sOutputFolder,  f"app_runner_workflow_s3m_{sDomainName}.json")
                with open(sConfigFile, 'w') as out_file:
                    out_file.write(sTemplateConfig)
    print(sStaticFile)