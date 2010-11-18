module Bazarcms
  class EmpresasController < ApplicationController

  unloadable

  layout "bazar"
  def index
    @empresas = Empresa.all
    puts @empresas.size
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @empresas }
    end
  end

  def show
    @empresa = Empresa.find(params[:id])

    respond_to do |format|
      format.html { render :action => "edit" }
      format.xml  { render :xml => @empresa }
    end
    
  end

  def new
    @empresa = Empresa.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @empresa }
    end
  end

  def edit
    puts "paso por el edit"
    puts params.inspect

    @empresa = Empresa.find_by_id(params[:id])
    if (@empresa.nil?) then
      @empresa = Empresa.new
      @empresa.id = params[:id]
      @empresa.user_id = params[:id]
      @empresa.nombre  = 'Escriba su nombre Aquí'
      @empresa.desc    = 'Describa su empresa'
      @empresa.fundada = 2005 
      @empresa.moneda = 0
    end
    
    $i = @empresa.fundada;
    $num = DateTime.now.year-1;

# relleno los datos financieros si no existen
    while $i < $num  do
      @eb = Bazarcms::Empresasdato.find_by_empresa_id_and_periodo(params[:id], $i)
      
      if (@eb.nil?) then
        @eb = Bazarcms::Empresasdato.new
        @eb.empresa_id = params[:id];
        @eb.periodo = $i
        @eb.empleados = 0
        @eb.ventas = 0
        @eb.compras = 0
        @eb.save
      end
      $i +=1;
    end
    
    
    @empresasdatos = Bazarcms::Empresasdato.find_by_empresa_id(params[:id])
       
    puts @empresa.inspect
    puts @empresasdatos.inspect

  end

  def create
    puts "pasa por el create "
    puts params.inspect
    @empresa = Empresa.new(params[:bazarcms_empresa])
    @empresa.user_id = current_user.id
    @empresa.id = current_user.id
    
    respond_to do |format|
      if @empresa.save
        puts "se ha creado la empresa:"+@empresa.id.to_s+' '+@empresa.user_id.to_s
        format.html { redirect_to(@empresa, :notice => 'Se ha creado correctamente la empresa.') }
        format.xml  { render :xml => @empresa, :status => :created, :location => @empresa }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @empresa.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    puts params.inspect
    @empresa = Empresa.find(params[:id])
    
    respond_to do |format|
      if @empresa.update_attributes(params[:bazarcms_empresa])
        # format.html { redirect_to(@empresa, :notice => 'Se ha actualizado correctamente la empresa.') }
        format.html { render :action => "edit" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @empresa.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @empresa = Empresa.find(params[:id])
    @empresa.destroy

    respond_to do |format|
      format.html { redirect_to(empresas_url) }
      format.xml  { head :ok }
    end
  end
end

end

