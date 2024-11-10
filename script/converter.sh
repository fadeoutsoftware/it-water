docker run \
-it \
--name converter \
--mount type=bind,source=/home/taxalb/data,target=/data \
docker.io/it-water/converter:dev

# docker cp hmc_tool_processing_sourcenc2nc_converter_s3m_fotest.json converter:/app/entrypoint

# docker exec -it converter bash
