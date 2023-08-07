FROM archlinux

WORKDIR /usr/src/bot
COPY stable_diffusion_bot .
COPY start.sh .
CMD [ "./start.sh" ]
