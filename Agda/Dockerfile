FROM haskell:8.4.3

RUN cabal update
RUN cabal install alex
RUN cabal install happy
RUN cabel install Agda-2.5.4.2

COPY . .

CMD ["agda", "-v", "2" , "all.agda"]

