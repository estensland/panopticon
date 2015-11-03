{
  models: [
    {
      model: :capture,
      attrs: {
        subject_id: :integer,
        act_id:  :integer,
        site_id:    :integer,
        session_id: :integer,
        params:     :hstore,
      },
      associations: {
        belongs_to: [
          :subject,
          :act,
          :site,
          :session
        ]
      },
      serializer: {
        params: :all
      },
      controllers: {
        strong_params: :none,
        standard:{
            routes: [:index, :show]
          },
        admin: {
          total_overlord: true
        },
        api: {
          v1:{
            strong_params: [:params, :act_id, :subject_id, :session_id],
            routes: [:index, :show, :create]
          }
        }
      }
    },
    {
      model: :act,
      attrs: {
        key:         :string,
        description: :text,
        site_id:     :integer,
      },
      associations: {
        belongs_to: [
          :site
        ]
      },
      serializer: {
        params: :all
      },
      controllers: {
        strong_params: :none,
        standard:{
            routes: [:index, :show, :edit, :update]
          },
        admin: {
          total_overlord: true
        },
        api: {
          v1:{
            strong_params: [:description],
            routes: [:index, :show, :update, :edit]
          }
        }
      }
    },
    {
      model: :subject,
      attrs: {
        email:       :string,
        params:      :hstore
      },
      associations: {
        belongs_to: [
          :site
        ]
      },
      serializer: {
        params: :all
      },
      controllers: {
        strong_params: :none,
        standard:{
          routes: [:index, :show]
        },
        admin: {
          total_overlord: true
        },
        api: {
          v1:{
            routes: [:index, :show]
          }
        }
      }
    },
    {
      model: :site,
      attrs: {
        name:       :string,
        auth_key:   :string
      },
      associations: {
        has_many: [
          :acts,
          :captures,
          :site_users,
          ':users, through: :site_users',
          ':surveys, through: :users',
          :reports
        ]
      },
      serializer: {
        params: :all
      },
      controllers: {
        strong_params: :none,
        standard:{
          routes: [:index, :show]
        },
        admin: {
          total_overlord: true
        },
        api: {
          v1:{
            routes: [:index, :show]
          }
        }
      }
    },
    {
      model: :surveys,
      attrs: {
        beginning:   :datetime,
        ending:      :datetime,
        user_id:     :integer,
        site_id:     :integer,
        is_public:   :boolean
      },
      associations: {
        belongs_to: [
          :user,
          :site
        ],
        has_many: [
          :acts,
          :captures,
          :act_surveys,
          ':acts, through: :act_surveys',
          ':captures, through: :acts',
          ':subjects, through: :captures'
        ]
      },
      serializer: {
        params: :all
      },
      controllers: {
        strong_params: [:beginning, :ending, :is_public],
        standard:{
          routes: [:index, :show, :edit, :create, :update, :new]
        },
        admin: {
          total_overlord: true
        },
        api: {
          strong_params: [:beginning, :ending, :is_public],
          v1:{
            routes: [:index, :show, :create, :edit, :update, :new]
          }
        }
      }
    },
    {
      model: :reports,
      attrs: {
        name:        :string,
        user_id:     :integer,
        site_id:     :integer
      },
      associations: {
        belongs_to: [
          :user
        ],
        has_many: [
          :filters,
          ':acts, through: :filters',
          ':captures, through: :acts',
        ]
      },
      serializer: {
        params: :all
      },
      controllers: {
        strong_params: [:name],
        standard:{
          routes: [:index, :show, :edit, :create, :update, :new]
        },
        admin: {
          total_overlord: true
        },
        api: {
          strong_params: [:name],
          v1:{
            routes: [:index, :show, :create, :edit, :update, :new]
          }
        }
      }
    },
    {
      model: :filters,
      attrs: {
        report_id:    :integer,
        is_public:    :boolean,
        params_name:  :string,
        params_value: :string,
        act_id:       :integer,
        params_name:  :string,
        filter_type:  :integer
      },
      associations: {
        belongs_to: [
          :report,
          :act
        ],
        has_many: [
          ':captures, through: :act',
          ':subjects, through: :captures',
        ]
      },
      serializer: {
        params: :all
      },
      controllers: {
        strong_params: [:report_id, :is_public, :params_name, :params_value, :act_id, :filter_type],
        standard:{
          routes: [:index, :show, :edit, :create, :update, :new]
        },
        admin: {
          total_overlord: true
        },
        api: {
          strong_params: [:report_id, :is_public, :params_name, :params_value, :act_id, :filter_type],
          v1:{
            routes: [:index, :show, :create, :edit, :update, :new]
          }
        }
      }
    }
  ],
  simple_joins: [
    [
      {models: ['act', 'survey']},
      {models: ['site', 'user']}
    ]
  ]
}