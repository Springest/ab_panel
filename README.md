[![Build Status](https://travis-ci.org/Springest/ab_panel.png?branch=master)](https://travis-ci.org/Springest/ab_panel)

# AbPanel

Run A/B test experiments on your Rails 3+ site using Mixpanel as a backend.

## Installation

Add this line to your application's Gemfile:

    gem 'ab_panel'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ab_panel

## Upgrading from 0.2.0 to 0.3.0

In this new version we've added weights to different conditions/scenarios. This
is so that you can rollout certain features slowly. We've also removed the
original (control scenario) that is added standard.

The only thing you need to do to upgrade is update the ``ab_panel.yml``.

Old:

```yaml

foo:
  - bar1
  - bar2

```

New (if you want to keep original or need original):

```yaml

foo:
  bar1: 2
  bar2: 2
  original: 2

```

## Usage

Create a config file with one or more experiments and conditions.

In `config/ab_panel.yml`

```yaml
my_experiment:
  original:    1
  condition_b: 1
  condition_c: 1
```

Note that this will create 3 conditions:

  1. Original condition 
  2. Condition B
  3. Condition C

You can add as many experiments and conditions as you want. Every visitor
will be assigned randomly to one condition for each scenario for as long as
their session remains active.

To track events in [Mixpanel](https://mixpanel.com), create a file called
`config/mixpanel.yml` with your api key, api secret, and the token of of your
project for every environment you want to run Mixpanel in, like so:

```yaml
production:
  api_key: 383340bfea74ab839ebb667ab3c59fa3
  api_secret: 3990703d6d73d2b7fd78a1d19de66605
  token: 735cc06a1b1ded4827d7faff385ad6fc
```

Enable the Mixpanel Middleware by adding it in the [necessary environments](example/config/environments/production.rb#L68):

```ruby
config.middleware.use Mixpanel::Middleware, AbPanel::Mixpanel::Config.token, persist: true
```

See [Mixpanel Gem docs](https://github.com/zevarito/mixpanel#rack-middleware) on the Middleware for more info.

In your application controller:

```ruby
class ApplicationController < ActionController::Base
  before_filter :initialize_ab_panel!
end
```

Then track any event you want from your controller:

```ruby
class CoursesController < ApplicationController
  def show
    track_action '[visits] Course', { :course => :id }
  end
end
```

You can track variables from within your controller actions:

```ruby
def show
  # A single variable
  track_variable :id, params[:id]

  # Or a hash with variables
  track_variables { id: params[:id], email: current_user.email }
end
```

Use conditions based on experiments and conditions throughout your code, e.g. in your views:

```erb
<% if AbPanel.my_experiment.condition_b? %>
  <p>Hi there, you are in Condition B in my experiment.</p>
<% else %>
  <p>Hi there, you are either in the Original condition or in Condition C in my experiment.</p>

  <% if AbPanel.my_experiment.condition_c? %>
    <p>Ah, you're in C.</p>
  <% end %>
<% end %>
```

Or in your controller:

```ruby
case AbPanel.my_experiment.condition
when 'condition_b'
  render 'my_experiment/condition_b'
when 'condition_c'
  render 'my_experiment/condition_c'
else
  render 'index'
end
```

Make sure to check the [Example App](https://github.com/Springest/ab_panel/tree/master/example)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
