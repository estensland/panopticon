{
  items: [
    {
      model: 'Capture',
      attrs: {
        subject_id: :integer,
        action_id:  :integer,
        site_id:    :integer,
        session_id: :integer,
        params:     :hstore,
      },
      associations: {
        belongs_to: [
          :subject,
          :action,
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
          routes: :all,
          strong_params: :all
        },
        api: {
          v1:{
            routes: [:index, :show, :create],
          }
        }
      }
    }
  ]
}