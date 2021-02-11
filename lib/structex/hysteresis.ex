defprotocol Structex.Hysteresis do
  @spec skeleton(t, Tensorex.t()) :: Tensorex.t()
  def skeleton(hysteresis, distortion)
  @spec equivalent_stiffness(t, Tensorex.t()) :: Tensorex.t()
  def equivalent_stiffness(hysteresis, distortion)
  @spec equivalent_damping_ratio(t, Tensorex.t()) :: number
  def equivalent_damping_ratio(hysteresis, distortion)
end
