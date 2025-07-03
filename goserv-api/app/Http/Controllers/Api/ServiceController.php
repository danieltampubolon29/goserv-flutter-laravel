<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Service;

class ServiceController extends Controller
{
    public function index()
    {
        return Service::all();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'customer_name' => 'required',
            'tanggal' => 'required|date',
            'jenis_kendaraan' => 'required',
            'nomor_polisi' => 'required',
            'service_items' => 'required|array',
            'harga' => 'required|integer',
        ]);

        $data['service_items'] = json_encode($data['service_items']);

        return Service::create($data);
    }

    public function destroy($id)
    {
        $service = Service::findOrFail($id);
        $service->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
