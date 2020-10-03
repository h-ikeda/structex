defmodule Structex.InsertedWoodenSidingWall do
  @moduledoc """
  Calculates rigidity and ultimate strength of the inserted wooden siding walls.
  Depending the following study.
  https://www.jstage.jst.go.jp/article/aijs/76/659/76_659_97/_article/-char/ja/
  """
  @doc """
  初期すべり変形角R0

  wall_inner_length - 軸組の内法幅
  wall_inner_height - 軸組の内法高さ
  horizontal_clearance - 柱と板小口とのクリアランス
  virtical_clearance - 梁と板長辺とのクリアランス
  """
  @spec first_slip_deformation_angle(
          wall_inner_length :: number,
          wall_inner_height :: number,
          horizontal_clearance :: number,
          virtical_clearance :: number
        ) :: float
  def first_slip_deformation_angle(l, h, cl, ch) when l > 0 and h > 0 and cl >= 0 and ch >= 0 do
    ((l - cl * 0.5) * cl + (h - ch * 0.5) * ch) / (l * h)
  end

  @doc """
  ダボのせん断による剛性Kdの逆数 (摩擦力を考慮した場合)

  single_connecter_rigidity - ダボ1本のせん断剛性
  connecter_number - 板1列あたりのダボ本数
  siding_width - 板幅
  wall_inner_height - 軸組の内法高さ
  wall_inner_width - 軸組の内法幅
  friction_coefficient - 板同士の摩擦係数
  """
  @spec shear_connecter_inverted_rigidity_with_friction(
          single_connecter_rigidity :: number,
          connecter_number :: pos_integer,
          siding_width :: number,
          wall_inner_height :: number,
          wall_inner_width :: number,
          friction_coefficient :: number
        ) :: float
  def shear_connecter_inverted_rigidity_with_friction(kd, nd, w, h, l, fc)
      when kd > 0 and is_integer(nd) and nd > 0 and w > 0 and h > 0 and l > 0 and fc >= 0 and
             h * fc / l >= 1 do
    0.0
  end

  def shear_connecter_inverted_rigidity_with_friction(kd, nd, w, h, l, fc)
      when kd > 0 and is_integer(nd) and nd > 0 and w > 0 and h > 0 and l > 0 and fc >= 0 do
    (floor(h / w) - 1) * (1 / h - fc / l) / nd / kd
  end

  @doc """
  板材のせん断剛性Ksの逆数

  shear_modulus - 板材のせん断弾性係数
  thickness - 板厚
  wall_inner_length - 軸組の内法幅
  """
  @spec siding_inverted_rigidity(
          shear_modulus :: number,
          thickness :: number,
          wall_inner_length :: number
        ) :: float
  def siding_inverted_rigidity(g, t, l) when g > 0 and t > 0 and l > 0, do: 1 / g / l / t

  @doc """
  板の圧縮筋かいゾーンの縮みによる剛性Kaの逆数

  fiber_direction_elasticity - 繊維方向のヤング係数
  elasticity_ratio - E‖ / E┴
  thickness - 板厚
  wall_inner_length - 軸組の内法幅
  wall_inner_height - 軸組の内法高さ
  """
  @spec diagonal_siding_zone_inverted_rigidity(
          fiber_direction_elasticity :: number,
          elasticity_ratio :: number,
          thickness :: number,
          wall_inner_length :: number,
          wall_inner_height :: number
        ) :: float
  def diagonal_siding_zone_inverted_rigidity(eh, er, t, l, h)
      when eh > 0 and er > 0 and t > 0 and l > 0 and h > 0 do
    (4 * :math.log(l) - :math.log(l * l + h * h) + h * h / l / l - 1) * (l * l + h * h * er) /
      (l * l + h * h) / eh / l / t
  end

  @doc """
  板端部の柱へのめりこみによる剛性Kcの逆数

  fiber_orthogonal_direction_elasticity - 柱の全面横圧縮ヤング係数
  column_depth - 柱の見付幅
  column_width - 柱の見込幅
  substitution_coefficient - 繊維方向に対する繊維直行方向の置換係数
  thickness - 板厚
  siding_width - 板幅
  wall_inner_height - 軸組の内法高さ
  """
  @spec column_side_inverted_rigidity(
          fiber_orthogonal_direction_elasticity :: number,
          column_depth :: number,
          column_width :: number,
          substitution_coefficient :: number,
          thickness :: number,
          siding_width :: number,
          wall_inner_height :: number
        ) :: float
  def column_side_inverted_rigidity(ec, dc, b, n, t, w, h)
      when ec > 0 and dc > 0 and b >= t and n > 0 and t > 0 and w > 0 and h > 0 do
    4 * dc / w / h / t / dent_coefficient(dc, b, t, n) / ec
  end

  @doc """
  板端部の柱へのめりこみによる剛性Kcの逆数 (板と横架材間がダボで止められている場合)

  fiber_orthogonal_direction_elasticity - 柱の全面横圧縮ヤング係数
  column_depth - 柱の見付幅
  column_width - 柱の見込幅
  substitution_coefficient - 繊維方向に対する繊維直行方向の置換係数
  thickness - 板厚
  siding_width - 板幅
  wall_inner_height - 軸組の内法高さ
  wall_inner_length - 軸組の内法幅
  connecter_number - 1列あたりのダボ本数
  single_connecter_rigidity - ダボ1本のせん断剛性
  friction_coefficient - 板と横架材の摩擦係数
  """
  @spec column_side_inverted_rigidity_with_shear_connecters(
          fiber_orthogonal_direction_elasticity :: number,
          column_depth :: number,
          column_width :: number,
          substitution_coefficient :: number,
          thickness :: number,
          siding_width :: number,
          wall_inner_height :: number,
          wall_inner_length :: number,
          connecter_number :: pos_integer,
          single_connecter_rigidity :: number,
          friction_coefficient :: number
        ) :: float
  def column_side_inverted_rigidity_with_shear_connecters(ec, dc, b, n, t, w, h, l, nd, kd, fc)
      when ec > 0 and dc > 0 and b >= t and n > 0 and t > 0 and w > 0 and h > 0 and l > 0 and
             is_integer(nd) and nd > 0 and kd > 0 and fc >= 0 do
    4 * dc / h / (w * t * dent_coefficient(dc, b, t, n) * ec + 2 * dc * nd * kd) *
      (1 - h / l * fc)
  end

  @doc """
  板端部の梁へのめりこみによる剛性Kcの逆数

  fiber_orthogonal_direction_elasticity - 梁の全面横圧縮ヤング係数
  beam_depth - 梁の見付幅
  beam_width - 梁の見込幅
  substitution_coefficient - 繊維方向に対する繊維直行方向の置換係数
  thickness - 板厚
  wall_inner_length - 軸組の内法幅
  wall_inner_height - 軸組の内法高さ
  """
  @spec beam_side_inverted_rigidity(
          fiber_orthogonal_direction_elasticity :: number,
          column_depth :: number,
          column_width :: number,
          substitution_coefficient :: number,
          thickness :: number,
          wall_inner_length :: number,
          wall_inner_height :: number
        ) :: float
  def beam_side_inverted_rigidity(eb, d, b, n, t, l, h)
      when eb > 0 and d > 0 and b >= t and n > 0 and t > 0 and l > 0 and h > 0 do
    108 / 7 * h * d / l / l / l / t / dent_coefficient(d, b, t, n) / eb
  end

  @spec dent_coefficient(number, number, number, number) :: float
  defp dent_coefficient(d, b, t, n) when d > 0 and b > 0 and t > 0 and n > 0 do
    1 + 4 / 3 * d * (1 - :math.exp(-3 / 4 * n * (b - t) / d)) / n / t
  end

  @doc """
  板壁の剛性Kの逆数

  Accepted parameters:
    shear_connecter_rigidity - ダボ1本のせん断剛性
    number_of_shear_connecters - 板1列あたりのダボ本数
    siding_width - 板幅
    frame_inner_height - 軸組の内法高さ
    frame_inner_width - 軸組の内法幅
    friction_coefficient - 摩擦係数
    shear_modulus - 板材のせん断弾性係数
    siding_thickness - 板厚
    siding_fiber_direction_elasticity - 板材の繊維方向ヤング係数
    elasticity_ratio - 板材の繊維方向ヤング係数に対する繊維直行方向ヤング係数の比
    column_fiber_orthogonal_direction_elasticity - 柱材の全面横圧縮ヤング係数
    beam_fiber_orthogonal_direction_elasticity - 梁材の全面横圧縮ヤング係数
    column_depth - 柱の見付幅
    beam_height - 梁せい
    column_width - 柱の見込幅
    beam_width - 梁幅
    column_substitution_coefficient - 柱材の繊維方向に対する繊維直行方向の置換係数
    beam_substitution_coefficient - 梁材の繊維方向に対する繊維直行方向の置換係数
  """
  @spec inverted_rigidity(map | keyword) :: float
  def inverted_rigidity(params) when is_list(params) do
    inverted_rigidity(Enum.into(params, %{}))
  end

  def inverted_rigidity(%{} = params) do
    kd = params.shear_connecter_rigidity
    nd = params.number_of_shear_connecters
    w = params.siding_width
    h = params.frame_inner_height
    l = params.frame_inner_width
    fc = params.friction_coefficient
    g = params.shear_modulus
    t = params.siding_thickness
    eh = params.siding_fiber_direction_elasticity
    er = params.elasticity_ratio
    ec = params.column_fiber_orthogonal_direction_elasticity
    eb = params.beam_fiber_orthogonal_direction_elasticity
    dc = params.column_depth
    d = params.beam_height
    b = params.column_width
    bb = params.beam_width
    nc = params.column_substitution_coefficient
    nb = params.beam_substitution_coefficient

    column_side_inverted_rigidity =
      if Map.get(params, :shear_connecters_between_beams_and_sidings) do
        column_side_inverted_rigidity_with_shear_connecters(ec, dc, b, nc, t, w, h, l, nd, kd, fc)
      else
        column_side_inverted_rigidity(ec, dc, b, nc, t, w, h)
      end

    shear_connecter_inverted_rigidity_with_friction(kd, nd, w, h, l, fc) +
      siding_inverted_rigidity(g, t, l) +
      diagonal_siding_zone_inverted_rigidity(eh, er, t, l, h) +
      column_side_inverted_rigidity +
      beam_side_inverted_rigidity(eb, d, bb, nb, t, l, h)
  end
end
