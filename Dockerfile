FROM ruby:3.1

LABEL org.opencontainers.image.source https://github.com/bluesentry/gitlab-repos-backup
RUN bundle config --global frozen 1
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.3.4
RUN bundle install
COPY . .

CMD ["ruby", "run.rb"]
