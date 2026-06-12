# Run container
# --dns points the container's system resolver at the on-box unbound recursive
# resolver (amnezia-dns @ 172.29.172.254 on amnezia-dns-net), with 1.1.1.1 as a
# fallback for the brief window before the dns-net is attached below. This keeps
# all VLESS/Reality name resolution on the box (no leak to the VPS provider's
# resolver). We deliberately do NOT use an xray `dns` app block for this — that
# path proved to hang the freedom outbound; the system-resolver route is robust.
sudo docker run -d \
--privileged \
--log-driver none \
--restart always \
--cap-add=NET_ADMIN \
--dns 172.29.172.254 \
--dns 1.1.1.1 \
-p $XRAY_SERVER_PORT:$XRAY_SERVER_PORT/tcp \
--name $CONTAINER_NAME $CONTAINER_NAME

sudo docker network connect amnezia-dns-net $CONTAINER_NAME

# Create tun device if not exist
sudo docker exec -i $CONTAINER_NAME bash -c 'mkdir -p /dev/net; if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi'

# Prevent to route packets outside of the container in case if server behind of the NAT
#sudo docker exec -i $CONTAINER_NAME sh -c "ifconfig eth0:0 $SERVER_IP_ADDRESS netmask 255.255.255.255 up"

