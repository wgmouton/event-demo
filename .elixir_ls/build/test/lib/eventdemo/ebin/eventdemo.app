{application,eventdemo,
             [{applications,[kernel,stdlib,elixir,logger]},
              {description,"eventdemo"},
              {modules,['Elixir.EventDemo.Connector.AWS',
                        'Elixir.EventDemo.Deamon.EventService',
                        'Elixir.Eventdemo','Elixir.HttpServer']},
              {registered,[]},
              {vsn,"0.1.0"}]}.
