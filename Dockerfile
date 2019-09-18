FROM alpine AS builder
RUN apk add \
	autoconf \
	libtool \
	automake \
	g++ \
	make \
	libuv \
	unbound-dev 

COPY . .
RUN ./autogen.sh && ./configure && make
RUN cat config.log

FROM alpine AS hnsd
RUN apk add --no-cache unbound
COPY --from=builder hnsd .
# Authoritative Resolver
EXPOSE 5359/udp
# Recursive Resolver
EXPOSE 5360/udp
ENTRYPOINT ["./hnsd", "--ns-host=0.0.0.0:5359", "--rs-host=0.0.0.0:5360"]

# Some arbitrary working seeds, since the default testnet ones are down.
CMD [\
"--seeds=\
ak2hy7feae2o5pfzsdzw3cxkxsu3lxypykcl6iphnup4adf2ply6a@138.68.61.31:13038,\
ajaqq7jwqrwixmvl64tzi3qfi7ynj3hmmtzmkyubtrljh4mwmh7ie@165.22.151.242:13038,\
"\
]
