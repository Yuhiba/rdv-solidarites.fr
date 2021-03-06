describe Admin::Creneaux::AgentSearchesController, type: :controller do
  context "with a secretaire signed_in" do
    let!(:agent) { create(:agent, :secretaire) }
    before(:each) { sign_in agent }

    describe "GET index html format" do
      let!(:organisation_id) { agent.organisation_ids.first }

      it "should return success" do
        get :index, params: { organisation_id: organisation_id }
        expect(response).to have_http_status(:success)
      end

      it "should render template index" do
        get :index, params: { organisation_id: organisation_id }
        expect(response).to render_template("index")
      end

      it "should assigns form with user_ids" do
        user = create(:user)
        get :index, params: { organisation_id: organisation_id, user_ids: [user.id] }
        expect(assigns(:form).user_ids).to eq([user.id.to_s])
      end
    end
  end
end
