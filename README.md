[![Build Status](https://travis-ci.org/Springest/ab_panel.png?branch=master)](https://travis-ci.org/Springest/ab_panel)

# AbPanel

Run A/B test experiments on your Rails 3+ site using Mixpanel as a backend.

Create a config file with one or more experiments and conditions.

In `config/ab_panel.yml`

```yaml
my_experiment:
  - condition_b
  - condition_c
```

Note that this will create 3 conditions:

  1. Original condition (control condition)
  2. Condition B
  3. Condition C

You can add as many experiments and conditions as you want. Every visitor
will be assigned randomly to one condition for each scenario for as long as
their session remains active.

In your application controller:

```ruby
class ApplicationController < ActionController::Base
  initialize_ab_panel!
end
```

Then track any event you want from your controller:

```ruby
class CoursesController < ApplicationController
  track_action '[visits] Booking form', { :only => :book_now,  :course => :id }

  # controller code here
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

## Installation

Add this line to your application's Gemfile:

    gem 'ab_panel'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ab_panel

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
