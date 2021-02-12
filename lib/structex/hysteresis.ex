defprotocol Structex.Hysteresis do
  @spec equivalent_stiffness(t, number) :: number
  def equivalent_stiffness(hysteresis, distortion)
  @spec equivalent_damping_ratio(t, number) :: number
  def equivalent_damping_ratio(hysteresis, distortion)
end
