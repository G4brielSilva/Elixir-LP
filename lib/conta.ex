defmodule Conta do
  defstruct usuario: Usuario, saldo: 1000

  @contas "contas.txt"

  def cadastrar(usuario) do
    #contas=busca_contas()
    case busca_por_email(usuario.email) do
      nil ->
        binary = [%__MODULE__{usuario: usuario}]  ++ busca_contas()
        |> :erlang.term_to_binary()
        File.write(@contas, binary)

        _ -> {:error, "Conta ja cadastrda"}
    end


  end


  def busca_contas do
    {:ok, binary } = File.read(@contas)
    :erlang.binary_to_term(binary)
  end

  def busca_por_email(email), do: Enum.find(busca_contas(), &(&1.usuario.email == email))

  def transferir(de, para, valor) do
      de =  busca_por_email(de.usuario.email)

      cond do
        valida_saldo(de.saldo, valor) -> {:error, "Saldo Insuficiente!"}
        true ->
          contas = busca_contas()
          contas = List.delete contas, de
          contas = List.delete contas, para

          de = %Conta{de | saldo: de.saldo - valor}
          para = %Conta{para | saldo: para.saldo + valor}
          contas = contas ++ [de, para]
          File.write(@contas, :erlang.term_to_binary(contas))

      end
  end

  defp valida_saldo(saldo, valor), do: saldo<valor
end
