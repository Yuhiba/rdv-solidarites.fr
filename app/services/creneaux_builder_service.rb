class CreneauxBuilderService < BaseService
  def initialize(motif_name, lieu, inclusive_date_range, **options)
    @motif_name = motif_name
    @lieu = lieu
    @inclusive_date_range = inclusive_date_range
    @options = options
    @for_agents = options.fetch(:for_agents, false)
    @agent_ids = options.fetch(:agent_ids, nil)
    @agent_name = options.fetch(:agent_name, false)
    @motif_location_type = options.fetch(:motif_location_type, nil)
  end

  def perform
    creneaux = plages_ouvertures.flat_map { |po| creneaux_for_plage_ouverture(po) }
    creneaux = creneaux.select { |c| c.starts_at >= Time.zone.now }
    uniq_by = @for_agents ? ->(c) { [c.starts_at, c.agent_id] } : ->(c) { c.starts_at }
    creneaux.uniq(&uniq_by).sort_by(&:starts_at)
  end

  private

  def plages_ouvertures
    @plages_ouvertures ||= PlageOuverture
      .for_motif_and_lieu_from_date_range(@motif_name, @lieu, @inclusive_date_range)
      .where(({ agent_id: @agent_ids } unless @agent_ids.nil?))
      .where(({ motifs: { location_type: @motif_location_type } } if @motif_location_type.present?))
  end

  def motifs_for_plage_ouverture(plage_ouverture)
    motifs = plage_ouverture.motifs.where(name: @motif_name).active
    @for_agents ? motifs : motifs.reservable_online
  end

  def creneaux_for_plage_ouverture(plage_ouverture)
    motifs_for_plage_ouverture(plage_ouverture)
      .flat_map { creneaux_for_plage_ouverture_and_motif(plage_ouverture, _1) }
  end

  def creneaux_for_plage_ouverture_and_motif(plage_ouverture, motif)
    plage_ouverture.occurences_for(@inclusive_date_range).flat_map do |occurence|
      CreneauxBuilderForDateService
        .perform_with(plage_ouverture, motif, occurence.starts_at.to_date, @lieu, inclusive_date_range: @inclusive_date_range, **@options)
    end
  end
end
