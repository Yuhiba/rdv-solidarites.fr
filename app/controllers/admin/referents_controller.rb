class Admin::ReferentsController < AgentAuthController
  def update
    user = policy_scope(User).find(params[:user_id])
    authorize(user)
    # TODO: impossible d'utiliser la policy(Agent) ici : il y a des agents de plusieurs services dans les referents.
    agents = current_organisation.agents.where(id: params[:user][:agent_ids])
    flash[:error] = "Erreur lors de la modification des référents" unless user.update(agents: agents)
    redirect_to admin_organisation_user_path(current_organisation, user)
  end
end
