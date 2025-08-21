<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Resource;

class ResourceController extends Controller{
    public function index(){
        return view("resources.index", ['resources' => Resource::orderBy('name') -> paginate(20)]);
    }
    
    public function create(){
        return view('resources.create');
    }
    
    public function store(Request $request){
        $data = $request->validate([
            'name'=> 'required|string|max:200',
            'description'=> 'nullable|string',
            'capacity'=> 'required|integer|min:1',
            'is_active'=> 'sometimes|boolean',

        ]);
        $data['is_active'] = $request->boolean('is_active');

        Resource::create($data);
        
        return redirect('')->route('resources.index')->with('status', 'Resource created');
    }

    public function show(Resource $resource){
        return view('resources.show', compact('resource'));
    }

    public function edit(Resource $resource){
        return view('resources.edit', compact('resource'));
    }

    public function destroy(Resource $resource){
        $resource->delete();
        return redirect()->route('resources.index')->with('status', 'Resource deleted') ;
    }
        

}